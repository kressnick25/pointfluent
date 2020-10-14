import 'dart:async';
import 'dart:ui';

import 'package:Pointfluent/auth/settings.dart';
import 'package:Pointfluent/widgets/ErrorMsg.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:flutter/services.dart';

import '../widgets/RenderView.dart';
import '../util/Size.dart';

// Parent widget is needed to get the model location from the navigator in the build function.
class SceneViewerPage extends StatelessWidget {
  static const routeName = "/sceneViewer";
  final UdManager udManager;

  const SceneViewerPage({this.udManager});

  bool _isUdsFileType(String filePath) {
    final fileExtension = filePath.substring(filePath.length - 4);
    return fileExtension == '.uds' || fileExtension == '.UDS';
  }

  @override
  Widget build(BuildContext context) {
    // We get the SceneViewerArgs here before SceneViewer is created as they
    // are required to contruct a SceneViewer
    final SceneViewerArgs args = ModalRoute.of(context).settings.arguments;
    if (args.modelLocation == null)
      throw new FormatException(
          "Model location was not provided to SceneViewer");
    if (!_isUdsFileType(args.modelLocation))
      throw new FormatException(
          "File type provided to SceneViewer was not a .uds model.");
    final screenSize = MediaQuery.of(context).size;

    return Container(
      child: SceneViewer(
        udManager,
        args.modelLocation,
        Size(screenSize.height.toInt(), screenSize.width.toInt()),
      ),
    );
  }
}

/// View a pointCloud using udSDK in a window of set dimension size
class SceneViewer extends StatefulWidget {
  final UdManager udManager;
  final Size dimensions;
  final String modelLocation;

  static const List<double> defaultCameraMatrix = [
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    0, -5, 0, 1 //
  ];

  /// Create a SceneViewer as well as a renderContext, renderTarget and load a pointCloud
  SceneViewer(this.udManager, this.modelLocation, this.dimensions);

  @override
  _SceneViewerState createState() => _SceneViewerState();
}

// This widget stores the cameraMatrix as state, so when we update the
// camera matrix it will trigger a widget re-render
class _SceneViewerState extends State<SceneViewer> {
  List<double> cameraMatrix;
  Future<bool> init;

  @override
  void initState() {
    super.initState();
    cameraMatrix = SceneViewer.defaultCameraMatrix;
    init = _initRender(widget.modelLocation, widget.dimensions);
  }

  Future<bool> _initRender(String modelLocation, Size dimensions) async {
    await widget.udManager.loadModel(modelLocation);
    await widget.udManager.renderInit(dimensions.width, dimensions.height);
    return true;
  }

  /// Free the memory allocated to udSDK objects when this widget unmounts
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: init,
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.hasData) {
              return MatrixGestureDetector(
                onMatrixUpdate:
                    (Matrix4 m, Matrix4 tm, Matrix4 sm, Matrix4 rm) {
                  List<double> temp = m.storage.buffer.asFloat64List();
                  setState(() => cameraMatrix = temp);
                },
                child: RenderView(
                    widget.udManager, widget.dimensions, cameraMatrix),
              );
            } else if (snapshot.hasError) {
              return Text("Error");
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}

/// Arguments required by a SceneViewer widget
class SceneViewerArgs {
  // either a url or a filepath
  final String modelLocation;

  SceneViewerArgs(this.modelLocation);
}
