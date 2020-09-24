import 'dart:typed_data';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udSdkLib.dart';
import 'package:vaultSDK/udConfig.dart';

class UdManager extends UdSDKClass {
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

  UdManager()
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
    renderTarget.setTargets(colorClearValue: 0xFFFF00FF);
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
