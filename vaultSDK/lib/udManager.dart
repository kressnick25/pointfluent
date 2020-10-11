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
    0, -5, 0, 1 //
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
    renderContext.renderInstance.setMatrix(pointCloud.header.storedMatrix);
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

  void test() {
    Function.apply(this.render, []);
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

/// Defines callable udManager methods and provides functions to invoke these
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

  static Response handleError(Function callback) {
    try {
      final data =
          callback(); // this may be null if callback does not return anything
      return Response(data: data);
    } catch (err) {
      return Response(error: err);
    }
  }

  // Because we can only comunicate with static messages between isolates,
  // we can't call an instance function from another Isolate.
  // This workaround to handle call each function works for the small amount of
  // function calls we need at the moment, may want another solution to scale
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

/// Describes a function to be executed in Isolate primitive types
class ExecutableFunction {
  final String name;
  final List<dynamic> params;

  ExecutableFunction(this.name, this.params) {
    if (!ManagerFns.contains(this.name)) {
      throw new Exception("Provided functionName was invalid");
    }
  }
}

/// A message to pass data/instructions from the main Isolate to the child Isolate
class Message {
  final ExecutableFunction function;
  final SendPort replyPort;
  final bool close;

  Message(this.function, this.replyPort, {this.close = false});
}

/// The format of a response from the child Isolate
class Response {
  final Exception error;
  final dynamic data;

  Response({this.error, this.data});

  bool get ok => error == null;
  bool get hasData => data != null;
}

/// Handles async udSDK functions in a seperate thread using Isolates
class UdManager extends UdSDKClass {
  // long-lived port for receiving messages
  ReceivePort _mainRPort;
  SendPort _echoPort;

  UdManager() : this._mainRPort = ReceivePort();

  /// spawn the child Isolate and get the sendPort
  Future setup() async {
    await Isolate.spawn(_spawnIsolate, _mainRPort.sendPort);
    _echoPort = await _mainRPort.first;
  }

  /// Send an `ExecutableFunction` to the child Isolate for execution and handle the `Response`
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

  /// Login to to udSDK
  ///
  /// Equivalent to `udContext_Connect`
  Future<void> login(String email, String password) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.login, [email, password]));
  }

  /// Load a PointCloud from the location to a `.uds` file
  Future<void> loadModel(String modelLocation) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.loadModel, [modelLocation]));
  }

  /// Setup udSDK objects before calling `render`
  Future<void> renderInit(int width, int height) async {
    await _sendFunction(
        ExecutableFunction(ManagerFns.renderInit, [width, height]));
  }

  /// Update the camera matrix of this render object
  Future<void> updateCamera(List<double> newMatrix) async {
    throw new Exception("Not Implemented");
  }

  /// Set udSDK config to ignore certificate security
  Future<void> setIgnoreCertificate(bool val) async {
    await _sendFunction(ExecutableFunction(ManagerFns.ignoreCert, [val]));
  }

  /// Render the loaded model and return the resulting color buffer
  Future<ByteBuffer> render() async {
    return await _sendFunction(ExecutableFunction(ManagerFns.render, []));
  }

  /// Free associated memory and close the child Isolate
  Future<void> cleanup() async {
    final rPort = ReceivePort();
    _echoPort.send(
        Message(ExecutableFunction(ManagerFns.dispose, []), rPort.sendPort));
    await rPort.first;
    rPort.close();

    // TODO find better way to send close message
    _echoPort.send(Message(null, null, close: true));
  }

  /// Initialisation code run by child Isolate on setup
  static void _spawnIsolate(SendPort sPort) async {
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
