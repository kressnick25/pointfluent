import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: ListTile(
              title: Text(
                'Change Email',
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
                'Change Password',
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),
              leading: Icon(Icons.settings),
              trailing: Icon(Icons.keyboard_arrow_right),
            ),
          ),
        ],
      ),
    );
  }
}
