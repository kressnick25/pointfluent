import 'package:flutter/material.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';
import './BitmapImage.dart';
import 'dart:typed_data';

/// Render a pointCloud and display the resulting buffer as an Image widget
class RenderView extends StatefulWidget {
  final UdManager udManager;
  final Size size;

  const RenderView(this.udManager, this.size);

  @override
  _RenderViewState createState() => _RenderViewState();
}

class _RenderViewState extends State<RenderView> {
  Future<ByteBuffer> _colorBuffer;

  @override
  void initState() {
    _colorBuffer = widget.udManager.render();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ByteBuffer>(
      future: _colorBuffer,
      builder: (BuildContext context, AsyncSnapshot<ByteBuffer> snapshot) {
        if (snapshot.hasData) {
          return BitmapImage(widget.size, snapshot.data);
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
