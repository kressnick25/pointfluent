import 'dart:async';
import 'dart:ui';

import 'package:Pointfluent/widgets/ErrorMsg.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';

import '../widgets/RenderView.dart';
import '../util/Size.dart';

// Parent widget is needed to get the model location from the navigator in the build function.
class SceneViewerPage extends StatelessWidget {
  static const routeName = "/sceneViewer";
  final UdContext udContext;

  const SceneViewerPage({this.udContext});

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

    return Container(
      child: SceneViewer(
        udContext,
        args.modelLocation,
        dimensions: Size(640, 480),
      ),
    );
  }
}

/// View a pointCloud using udSDK in a window of set dimension size
class SceneViewer extends StatefulWidget {
  final UdContext udContext;
  final UdPointCloud pointCloud;
  final UdRenderContext renderContext;
  final UdRenderTarget renderTarget;
  final Size renderSize;
  final String modelLocation;

  static const List<double> defaultCameraMatrix = [
    1, 0, 0, 0, //
    0, 1, 0, 0, //
    0, 0, 1, 0, //
    5, -75, 5, 1 //
  ];

  /// Create a SceneViewer as well as a renderContext, renderTarget and load a pointCloud
  SceneViewer(this.udContext, this.modelLocation, {Size dimensions})
      // Set these properties as they are final
      : this.renderSize = dimensions,
        this.pointCloud = UdPointCloud(),
        this.renderContext = UdRenderContext(),
        this.renderTarget =
            UdRenderTarget(dimensions.width, dimensions.height) {
    renderContext.create(udContext);
    renderTarget.create(udContext, renderContext);
    // Load point cloud
    pointCloud.load(udContext, modelLocation);
    // finish setting up render context
    renderContext.setRenderInstancePointCloud(pointCloud);
    renderContext.renderInstance.setMatrix(defaultCameraMatrix);

    renderTarget.setTargets();
    renderTarget.setMatrix(
        udRenderTargetMatrix.udRTM_Camera, defaultCameraMatrix);
  }

  @override
  _SceneViewerState createState() => _SceneViewerState();
}

// This widget stores the cameraMatrix as state, so when we update the
// camera matrix it will trigger a widget re-render
class _SceneViewerState extends State<SceneViewer> {
  List<double> cameraMatrix;

  @override
  void initState() {
    super.initState();
    cameraMatrix = SceneViewer.defaultCameraMatrix;
  }

  /// Free the memory allocated to udSDK objects when this widget unmounts
  @override
  void dispose() {
    widget.pointCloud.unLoad();
    widget.renderTarget.destroy();
    widget.renderContext.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RenderView(widget.renderContext, widget.renderTarget, cameraMatrix,
        widget.renderSize);
  }
}

/// Arguments required by a SceneViewer widget
class SceneViewerArgs {
  // either a url or a filepath
  final String modelLocation;

  SceneViewerArgs(this.modelLocation);
}
