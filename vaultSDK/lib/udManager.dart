import 'dart:typed_data';
import 'dart:isolate';
import 'dart:async';
import 'dart:developer';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udSdkLib.dart';
import 'package:vaultSDK/udConfig.dart';

/// Internal synchronous version of UdManager, managed by Isolate
class _UdManager extends UdSDKClass {
  final UdContext udContext;
  final UdPointCloud pointCloud;
  final UdRenderContext renderContext;
  UdRenderTarget renderTarget;
  static const List<double> defaultCameraMatrix = [
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    5, -75, 5, 1 //
  ];

  _UdManager()
      : this.udContext = UdContext(),
        this.pointCloud = UdPointCloud(),
        this.renderContext = UdRenderContext();

  void login(String email, String password) {
    this.udContext.connect(email, password);
  }

  void loadModel(String modelLocation) {
    this.pointCloud.load(udContext, modelLocation);
  }

  void renderInit(int width, int height) {
    this.renderContext.create(udContext);
    this.renderTarget = UdRenderTarget(width, height);
    renderTarget.create(udContext, renderContext);
    renderContext.setRenderInstancePointCloud(pointCloud);
    renderContext.renderInstance.setMatrix(defaultCameraMatrix);
    renderTarget.setTargets(colorClearValue: 0);
    renderTarget.setMatrix(
        udRenderTargetMatrix.udRTM_Camera, defaultCameraMatrix);

    renderContext.renderSettings.flags =
        udRenderContextFlags.udRCF_BlockingStreaming;
  }

  void updateCamera(List<double> newMatrix) {
    throw new Exception("Not Implemented");
  }

  void render() {
    this.renderContext.render(renderTarget);
  }

  void setIgnoreCertificate(bool val) {
    UdConfig.ignoreCertificateVerification(val);
  }

  @override
  void dispose() {
    pointCloud.unLoad();
    renderTarget.destroy();
    renderContext.destroy();
    udContext.disconnect();
    super.dispose();
  }

  ByteBuffer get colorBuffer => this.renderTarget.colorBuffer.buffer;
}

abstract class ManagerFns {
  static const login = "login";
  static const loadModel = "loadModel";
  static const renderInit = "renderInit";
  static const ignoreCert = "ignoreCert";
  static const render = "render";
  static const dispose = "dispose";

  static const allFns = [
    login,
    loadModel,
    renderInit,
    ignoreCert,
    render,
    dispose
  ];

  static bool contains(String functionName) {
    return allFns.contains(functionName);
  }

  static Response handleError(callback) {
    try {
      final data =
          callback(); // this may be null if callback does not return anything
      return Response(data: data);
    } catch (err) {
      return Response(error: err);
    }
  }

  static Response doFunction(
      _UdManager manager, String functionName, List<dynamic> params) {
    switch (functionName) {
      case login:
        {
          return handleError(() => manager.login(params[0], params[1]));
        }
        break;
      case loadModel:
        {
          return handleError(() => manager.loadModel(params[0]));
        }
        break;
      case renderInit:
        {
          return handleError(() => manager.renderInit(params[0], params[1]));
        }
        break;
      case ignoreCert:
        {
          return handleError(() => manager.setIgnoreCertificate(params[0]));
        }
        break;
      case render:
        {
          return handleError(() {
            manager.render();
            return manager
                .colorBuffer; // TODO copy to new array or use TransferableByteData
          });
        }
        break;
      case dispose:
        {
          return handleError(() => manager.dispose());
        }
        break;
      default:
        {
          return Response(
              error: Exception("Invalid function call passed to udManager"));
        }
        break;
    }
  }
}

class ExecutableFunction {
  final String name;
  final List<dynamic> params;

  ExecutableFunction(this.name, this.params) {
    if (!ManagerFns.contains(this.name)) {
      throw new Exception("Provided functionName was invalid");
    }
  }
}

class Message {
  final ExecutableFunction function;
  final SendPort replyPort;
  final bool close;

  Message(this.function, this.replyPort, {this.close = false});
}

class Response {
  final Exception error;
  final dynamic data;

  Response({this.error, this.data});

  bool get ok => error == null;
  bool get hasData => data != null;
}

class UdManager extends UdSDKClass {
  // long-lived port for receiving messages
  ReceivePort _mainRPort;
  SendPort _echoPort;

  UdManager() : this._mainRPort = ReceivePort();

  Future setup() async {
    await Isolate.spawn(_doIsolateWork, _mainRPort.sendPort);
    _echoPort = await _mainRPort.first;
  }

  Future<dynamic> _sendFunction(ExecutableFunction fn) async {
    // Setup a new receivePort as these can only be used once
    final rPort = ReceivePort();
    // send a message to the Isolate and get the response
    _echoPort.send(Message(fn, rPort.sendPort));
    Response response = await rPort.first;
    // must call rPort.close() once not in use otherwise will remain open/ leak memory
    rPort.close();

    if (!response.ok) throw response.error;
    if (response.hasData) return response.data;
  }

  Future<void> login(String email, String password) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.login, [email, password]));
  }

  Future<void> loadModel(String modelLocation) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.loadModel, [modelLocation]));
  }

  Future<void> renderInit(int width, int height) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.renderInit, [width, height]));
  }

  Future<void> updateCamera(List<double> newMatrix) async {
    throw new Exception("Not Implemented");
  }

  Future<void> setIgnoreCertificate(bool val) async {
    await _sendFunction(ExecutableFunction(ManagerFns.ignoreCert, [val]));
  }

  Future<ByteBuffer> render() async {
    return await _sendFunction(ExecutableFunction(ManagerFns.render, []));
  }

  Future<void> cleanup() async {
    final rPort = ReceivePort();
    _echoPort.send(
        Message(ExecutableFunction(ManagerFns.dispose, []), rPort.sendPort));
    await rPort.first;
    rPort.close();

    // TODO find better way to send close message
    _echoPort.send(Message(null, null, close: true));
  }

  static void _doIsolateWork(SendPort sPort) async {
    // open receivePort to get work
    var isolateRPort = ReceivePort();
    _UdManager manager = _UdManager();
    // tell main thread our recievePort so it can send us work
    sPort.send(isolateRPort.sendPort);

    // wait for new messages and respond
    await for (Message msg in isolateRPort) {
      if (msg.close) {
        isolateRPort.close();
        break;
      }
      final response = ManagerFns.doFunction(
          manager, msg.function.name, msg.function.params);
      msg.replyPort.send(response);
    }
  }
}
