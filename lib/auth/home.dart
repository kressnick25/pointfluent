import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer';

import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udContext.dart';

import '../widgets/ErrorMsg.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.udContext}) : super(key: key);
  static const routeName = '/home';

  final UdContext udContext;
  final pointCloud = UdPointCloud();
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _errMessage;

  void _handleFileSelect() async {
    var filePath = await FilePicker.getFilePath(type: FileType.any);
    // Would preferably use the following to limit to just `uds` files
    // Currently doing this on Android limits the selection to photos for some reason
    // getFilePath(type: FileType.custom, allowedExtensions: ['uds']);

    try {
      widget.pointCloud.load(widget.udContext, filePath);
      setState(() => _errMessage = null);
    } catch (err) {
      setState(() => _errMessage = err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff8f8f8),
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
          Container(
            margin: const EdgeInsets.only(top: 12),
            color: Color(0xffffffff),
            child: ListTile(
              title: Text(
                'Most Recent',
                style: const TextStyle(fontSize: 16, letterSpacing: -0.3),
              ),
              // leading: Icon(Icons.storage),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            color: Color(0xffffffff),
            child: ListTile(
                title: Text(
                  'Select File',
                  style: const TextStyle(
                    fontSize: 22,
                  ),
                ),
                leading: Icon(Icons.folder),
                trailing: Icon(Icons.keyboard_arrow_right),
                onTap: () => _handleFileSelect()),
          ),
          Card(
            child: ListTile(
              title: Text(
                'Settings',
                style: const TextStyle(fontSize: 16, letterSpacing: -0.3),
              ),
              // leading: Icon(Icons.settings),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 12),
            color: Color(0xffffffff),
            child: ListTile(
              title: Text(
                'Logout',
                style: const TextStyle(fontSize: 16, letterSpacing: -0.3),
              ),
              // leading: Icon(Icons.eject),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.popAndPushNamed(context, '/'),
            ),
          ),
          ErrorMsg(message: _errMessage),
        ],
      ),
    );
  }
}
