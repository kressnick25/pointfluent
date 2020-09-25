import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../util/Size.dart';
import '../util/Bitmap.dart';

/// Currently unused Widget but provides an alternate way
/// to convert `renderTarget.colorBuffer` to a usable Image widget
class BitmapImage extends StatelessWidget {
  final ByteBuffer _buffer;
  final Size size;
  final int quarterRotations;

  BitmapImage(this.size, this._buffer, {this.quarterRotations});

  @override
  Widget build(BuildContext context) {
    final bitmap =
        Bitmap.fromHeadless(size.width, size.height, _buffer.asUint8List());
    final headedBitmap = bitmap.buildHeaded();

    return RotatedBox(
        quarterTurns: this.quarterRotations, child: Image.memory(headedBitmap));
  }
}
