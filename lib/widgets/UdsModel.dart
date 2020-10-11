import 'package:flutter/material.dart';

import '../auth/sceneViewer.dart';

class UdsModel extends StatelessWidget {
  final ModelType type;
  final String location; // either URL or filePath
  final String name;

  UdsModel({Key key, this.type, this.location})
      : this.name = _parseName(location),
        super(key: key);

  /// Returns the filename of a file from url or filePath
  static String _parseName(String location) {
    final split = location.split("/");
    final filename = split.last;
    // Trim '.uds' from end of line
    final name = filename.split(".");
    final fileExtension = name.removeLast();

    if (fileExtension != 'uds' && fileExtension != 'UDS') {
      throw FormatException("File selected was not of UDS type");
    }

    return name.join();
  }

  _iconImage() {
    if (this.type == ModelType.url) return Icons.http;
    if (this.type == ModelType.filePath) return Icons.description;
  }

  _onPressed(context) {
    // Go to scene viewer page, providing file location
    Navigator.pushNamed(
      context,
      SceneViewerPage.routeName,
      arguments: SceneViewerArgs(this.location),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).primaryColor;

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              _iconImage(),
              color: iconColor,
            ),
            tooltip: 'Open in Scene Viewer',
            onPressed: _onPressed(context),
          ),
          Text(this.name),
        ],
      ),
    );
  }
}

enum ModelType {
  url,
  filePath,
}
