import 'package:flutter/material.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:image/image.dart' as img;

import '../util/Size.dart';
import 'BitmapImage.dart';
import 'dart:typed_data';

/// IMPORTANT
///
/// This variable controls the wait time between renders
/// setting this to a lower variable will make the scene run smoother
/// HOWEVER, if the value is set to low, nothing will be shown on screen.
/// We find 32 to be a good comprimise between smoothness and
/// guaranteeing the app will work properly.
const RENDER_DELAY_MS = 32;

/// Render a pointCloud and display the resulting buffer as an Image widget using Streams
///
/// This creates a Stream that calls UdManager.render every renderDelayMs milliseconds.
/// A re-render will occur every once the render call is
class RenderViewStream extends StatelessWidget {
  final UdManager udManager;
  final Size size;

  /// Convert render Future to a stream that emits a ByteBuffer every renderDelay(ms)
  //
  // This isn't the best use of Streams but is better than refreshing a Future.
  // A better implementation would have the UdManager setup a Stream that contstantly
  // renders and emits a colorBuffer ByteBuffer on each render completion.
  // Then this component could subscribe to that stream with a listener so
  // it would re-paint on each completed render rather than re-rendering after
  //  an arbitrary amount of time.
  Stream<ByteBuffer> _colorBufferStream() async* {
    yield* Stream.periodic(Duration(milliseconds: RENDER_DELAY_MS), (_) async {
      return await udManager.render();
    }).asyncMap((event) async => await event);
  }

  RenderViewStream(this.udManager, this.size);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _colorBufferStream(),
      builder: (context, AsyncSnapshot<ByteBuffer> snapshot) {
        if (snapshot.hasData) {
          return BitmapImage(size, snapshot.data, quarterRotations: 0);
        } else if (snapshot.hasError) {
          return Text("Error");
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
