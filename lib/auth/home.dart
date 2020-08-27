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
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(
                'Most Recent',
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              leading: Icon(Icons.storage),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
          Card(
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
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              leading: Icon(Icons.settings),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(
                'Logout',
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              leading: Icon(Icons.eject),
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
