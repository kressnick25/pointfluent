import 'package:Pointfluent/widgets/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer';

import '../widgets/ErrorMsg.dart';
import '../auth/sceneViewer.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);
  static const routeName = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ErrorMsg _error = ErrorMsg();
  static const double marginTop = 12;

  void _handleFileSelect() async {
    var filePath = await FilePicker.getFilePath(type: FileType.any);
    // Would preferably use the following to limit to just `uds` files
    // Currently doing this on Android limits the selection to photos for some reason
    // getFilePath(type: FileType.custom, allowedExtensions: ['uds']);

    Navigator.pushNamed(
      context,
      SceneViewerPage.routeName,
      arguments: SceneViewerArgs(filePath),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        elevation: 0,
        title:
            Text('Home', style: TextStyle(color: Colors.white, fontSize: 26)),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Color.fromRGBO(24, 189, 210, 1.0),
            child: ListTile(
              title: Text(
                'Enter Scene Viewer',
                style: const TextStyle(
                    color: Colors.white, fontSize: 18, letterSpacing: -0.3),
              ),
              trailing: Icon(Icons.keyboard_arrow_right, color: Colors.white),
            ),
          ),
          MenuItem(
              title: 'Most Recent',
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => _handleFileSelect(),
              margin: const EdgeInsets.only(top: marginTop),),
          MenuItem(
              title: 'Settings',
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.pushNamed(context, '/settings'),
              margin: const EdgeInsets.only(top: marginTop),),
          MenuItem(
              title: 'Logout',
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.popAndPushNamed(context, '/'),
              margin: const EdgeInsets.only(top: marginTop),),
        ],
      ),
    );
  }
}
