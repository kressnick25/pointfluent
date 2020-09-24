import 'dart:developer';
import 'dart:io';

// import 'package:path_provider/path_provider.dart';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udConfig.dart';

import 'util/Bitmap.dart';

const List<double> cameraMatrix = [
  1, 0, 0, 0, //
  0, 1, 0, 0, //
  0, 0, 1, 0, //
  5, -75, 5, 1 //
];

Future<File> writeBitmap(List<int> bytes) async {
  // final directory = await getExternalStorageDirectory();
  // final path = directory.path;
  const path = "/storage/emulated/0/Android/data/com.example.Pointfluent/files";
  final file = File('$path/render.bmp');

  // Write the file.
  return file.writeAsBytes(bytes);
}

void main() {
  final width = 1920;
  final height = 1080;
  final username = ""; // INSERT
  final password = ""; // INSERT
  final modelName = "https://models.euclideon.com/DirCube.uds";

  final udContext = UdContext();
  final renderContext = UdRenderContext();
  final renderTarget = UdRenderTarget(width, height);
  final pointCloud = UdPointCloud();

  UdConfig.ignoreCertificateVerification(true);
  udContext.connect(username, password);

  renderContext.create(udContext);

  renderTarget.create(udContext, renderContext);

  pointCloud.load(udContext, modelName);
  renderContext.setRenderInstancePointCloud(pointCloud);

  renderContext.renderInstance.setMatrix(cameraMatrix);

  renderTarget.setTargets(colorClearValue: 0);

  renderTarget.setMatrix(udRenderTargetMatrix.udRTM_Camera, cameraMatrix);
  renderContext.renderSettings.flags =
      udRenderContextFlags.udRCF_BlockingStreaming;

  renderContext.render(renderTarget, modelCount: 1);

  Bitmap bitmap = Bitmap.fromHeadless(
      width, height, renderTarget.colorBuffer.buffer.asUint8List());
  final headedBitmap = bitmap.buildHeaded();

  writeBitmap(headedBitmap);

  // Cleanup
  pointCloud.unLoad();
  renderTarget.destroy();
  renderContext.destroy();
  udContext.disconnect();

  log("Exit 0");
}
