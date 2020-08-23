import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer';

class HomePage extends StatelessWidget {
  static const routeName = '/home';

  @override
  Widget build(BuildContext context) {
    String _filepath;

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
                onTap: () async {
                  _filepath = await FilePicker.getFilePath();
                  log(_filepath);
                }),
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
        ],
      ),
    );
  }
}
