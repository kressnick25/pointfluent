import 'package:flutter/material.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';

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

    // convert the Int32List from udSDK to a format that the Image.memory widget can parse...
    // this will likely be less performant than passing the raw renderTarget.colorBuffer
    // directly to a canvas or widget, but apparently there is not currently a way to do this
    // (some of the implementations use a Uint8List but then we have to convert
    // 32bit argb to 8bit rgb with a color table anyway)
    final image = img.Image.fromBytes(
        size.width, size.height, renderTarget.colorBuffer,
        format: img.Format.argb);
    final List<int> buffer = img.encodeJpg(image);

    return Container(
      child: Image.memory(buffer),
    );
  }
}
