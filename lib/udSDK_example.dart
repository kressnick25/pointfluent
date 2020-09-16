import 'dart:developer';
import 'dart:ffi';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udConfig.dart';

const List<double> cameraMatrix = [
  1, 0, 0, 0, //
  0, 1, 0, 0, //
  0, 0, 1, 0, //
  5, -75, 5, 1 //
];

void main() {
  final width = 640;
  final height = 480;
  final username = "kressnick25@gmail.com";
  final password = "Gizzhead12";
  final modelName = "https://models.euclideon.com/DirCube.uds";

  final udContext = UdContext();
  final renderContext = UdRenderContext();
  final renderTarget = UdRenderTarget(width * height);
  final pointCloud = UdPointCloud();

  UdConfig.ignoreCertificateVerification(true);
  udContext.connect(username, password);

  renderContext.create(udContext);

  renderTarget.create(udContext, renderContext, width, height);

  pointCloud.load(udContext, modelName);
  renderContext.renderInstance.pPointCloud =
      Pointer.fromAddress(pointCloud.address);

  renderContext.renderInstance.setMatrix(cameraMatrix);

  renderTarget.setTargets();

  renderTarget.setMatrix(udRenderTargetMatrix.udRTM_Camera, cameraMatrix);
  renderContext.renderSettings.flags =
      udRenderContextFlags.udRCF_BlockingStreaming;

  try {
    renderContext.render(renderTarget, 1);
  } catch (e) {
    log(e.toString());
  }

  pointCloud.unLoad();
  renderTarget.destroy();
  renderContext.destroy();
  udContext.disconnect();

  log("Exit 0");
}
