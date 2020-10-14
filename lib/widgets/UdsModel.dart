import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/sceneViewer.dart';
import './RecentModels.dart';

class UdsModel extends StatelessWidget {
  final ModelType type;
  final String location; // either URL or filePath
  final String name;

  UdsModel({Key key, this.location})
      : this.name = _parseName(location),
        this.type = _determineType(location),
        super(key: key);

  static ModelType _determineType(String location) {
    // Not great validation but just checking if http:// or /local
    final split = location.split(':');
    final isUrl = split.first == 'http' || split.first == 'https';
    return isUrl ? ModelType.url : ModelType.filePath;
  }

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
    var recentFiles = Provider.of<RecentModelsData>(context, listen: false);
    recentFiles.add(this.location);

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
    // return Container(child: Text(name));
    return Card(
      child: InkWell(
        onTap: () => _onPressed(context),
        child: Container(
          height: 90,
          width: 90,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconImage(),
                color: iconColor,
              ),
              Text(
                this.name,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ModelType {
  url,
  filePath,
}
