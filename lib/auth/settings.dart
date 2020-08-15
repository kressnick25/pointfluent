import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPracticeApp',
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: SettingsPageOptions(),
      ),
    );
  }
}

class SettingsPageOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
    );
  }
}
