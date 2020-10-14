import 'package:flutter/material.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';
import './BitmapImage.dart';
import 'dart:typed_data';

/// Render a pointCloud and display the resulting buffer as an Image widget
class RenderView extends StatelessWidget {
  final UdManager udManager;
  final Size size;
  final List<double> cameraMatrix;
  final Future<ByteBuffer> _colorBuffer;

  RenderView(this.udManager, this.size, this.cameraMatrix)
      : _colorBuffer = udManager.render(cameraMatrix);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteBuffer>(
      future: _colorBuffer,
      builder: (BuildContext context, AsyncSnapshot<ByteBuffer> snapshot) {
        if (snapshot.hasData) {
          return BitmapImage(size, snapshot.data, quarterRotations: 0);
        } else if (snapshot.hasError) {
          return Text("Error");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
    // child: BitmapImage(widget.size, colorBuffer)
  }
}
