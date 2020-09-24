import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../util/Size.dart';
import '../util/Bitmap.dart';

/// Currently unused Widget but provides an alternate way
/// to convert `renderTarget.colorBuffer` to a usable Image widget
class BitmapImage extends StatelessWidget {
  final ByteBuffer buffer;
  final Size size;

  BitmapImage(this.size, this.buffer);

  @override
  Widget build(BuildContext context) {
    final bitmap =
        Bitmap.fromHeadless(size.width, size.height, buffer.asUint8List());
    final headedBitmap = bitmap.buildHeaded();

    return Image.memory(headedBitmap);
  }
}
