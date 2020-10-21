import 'dart:developer';
import 'dart:io';

// import 'package:path_provider/path_provider.dart';

import 'package:vaultSDK/udManager.dart';
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

// udSDK async
void main() async {
  final width = 1920;
  final height = 1080;
  final username = "kressnick25@gmail.com"; // INSERT
  final password = "Gizzhead12"; // INSERT
  final modelName = "https://models.euclideon.com/DirCube.uds";

  final manager = UdManager();
  await manager.setup();

  await manager.setIgnoreCertificate(true);
  await manager.login(username, password);

  await manager.loadModel(modelName);

  await manager.renderInit(width, height);
  await manager.updateCamera(cameraMatrix);

  final buffer = await manager.render();

  Bitmap bitmap = Bitmap.fromHeadless(width, height, buffer.asUint8List());
  final headedBitmap = bitmap.buildHeaded();

  writeBitmap(headedBitmap);

  // Cleanup
  manager.cleanup();

  log("Exit 0");
}
