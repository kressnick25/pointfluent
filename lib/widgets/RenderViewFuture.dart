import 'package:flutter/material.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';
import './BitmapImage.dart';
import 'dart:typed_data';

/// Render the view using FutureBuilder
/// This component will not re-render unless the Future updates or
/// the state of the parent component updates
class RenderViewFuture extends StatelessWidget {
  final UdManager udManager;
  final Size size;
  final List<double> cameraMatrix;
  final Future<ByteBuffer> _colorBuffer;

  RenderViewFuture(this.udManager, this.size, this.cameraMatrix)
      : _colorBuffer = udManager.render(cameraMatrix);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteBuffer>(
      future: _colorBuffer,
      builder: (BuildContext context, AsyncSnapshot<ByteBuffer> snapshot) {
        if (snapshot.hasData) {
          return BitmapImage(size, snapshot.data, quarterRotations: 1);
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
