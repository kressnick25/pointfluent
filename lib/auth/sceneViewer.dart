import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:ffi';
import 'dart:typed_data';
// import 'dart:convert';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udConfig.dart';
import 'package:bitmap/bitmap.dart';

import 'package:vaultSDK/udError.dart';
import 'package:flutter/foundation.dart';

const List<double> cameraMatrix = [
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  5,
  -75,
  5,
  1
];

class SceneViewer extends StatefulWidget {
  static const routeName = '/sceneViewer';
  Int64List colorBuffer;
  Uint8List headedBitmap;
  Image image;
  SceneViewer({Key key}) : super(key: key) {
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

    // this.image = Image.memory(Uint8List.fromList(renderTarget.colorBuffer),
    //     width: width.toDouble(), height: height.toDouble());
    final bytes = Uint8List.fromList(renderTarget.colorBuffer);
    Bitmap headlessBmp = Bitmap.fromHeadless(width, height, bytes);
    this.headedBitmap = headlessBmp.buildHeaded();
    this.image = Image.memory(this.headedBitmap, fit: BoxFit.none);
    this.colorBuffer = renderTarget.colorBuffer;
    // for (int i = 0; i < renderTarget.colorBuffer.length; i++) {
    //   if (renderTarget.colorBuffer[i] != 0) {
    //     log(renderTarget.colorBuffer[i].toString());
    //   }
    // }
    // log(renderTarget.colorBuffer.toString());
  }

  @override
  _SceneViewerState createState() => _SceneViewerState();
}

class _SceneViewerState extends State<SceneViewer> {
  Future<ui.Image> getImage() async {
    final bytes = Uint8List.fromList(widget.colorBuffer);
    assert(widget.colorBuffer.length == bytes.length);
    log(bytes.length.toString());
    final ui.Codec codec = await ui.instantiateImageCodec(bytes,
        targetHeight: 480, targetWidth: 640);
    final ui.Image finalImage = (await codec.getNextFrame()).image;
    return finalImage;
  }

  @override
  Widget build(BuildContext context) {
    // ui.Image image;
    // // final bytes = Uint8List.fromList(widget.colorBuffer);
    // // assert(bytes.length == widget.colorBuffer.length);
    // ui.decodeImageFromList(widget.bmp, (result) {
    //   image = result;
    // });
    final image = Image.memory(widget.headedBitmap, fit: BoxFit.none);
    return Container(
      // child: FutureBuilder<ui.Image>(
      //   future: getImage(),
      //   builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
      //     switch (snapshot.connectionState) {
      //       case ConnectionState.waiting:
      //         return new Text('Image loading...');
      //       default:
      //         if (snapshot.hasError)
      //           return new Text('Error: ${snapshot.error}');
      //         else
      //           // ImageCanvasDrawer would be a (most likely) statless widget
      //           // that actually makes the CustomPaint etc
      //           return ImageCanvasDrawer(image: snapshot.data);
      //     }
      child: Text("Not loaded"),

      //   },
      // ),
    );
  }
}

class ImageCanvasDrawer extends CustomPaint {
  final ui.Image image;
  const ImageCanvasDrawer({Key key, this.image}) : super(key: key);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(this.image, Offset(0, 0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}
