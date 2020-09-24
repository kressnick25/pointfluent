import 'package:flutter/material.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';
import './BitmapImage.dart';
import 'dart:typed_data';

/// Render a pointCloud and display the resulting buffer as an Image widget
class RenderView extends StatelessWidget {
  final List<double> cameraMatrix;
  final UdRenderContext renderContext;
  final UdRenderTarget renderTarget;
  final Size size;

  const RenderView(
      this.renderContext, this.renderTarget, this.cameraMatrix, this.size);

  @override
  Widget build(BuildContext context) {
    renderTarget.setMatrix(udRenderTargetMatrix.udRTM_Camera, cameraMatrix);
    renderContext.render(renderTarget);

    return Container(
      child: BitmapImage(size, renderTarget.colorBuffer.buffer),
    );
  }
}
