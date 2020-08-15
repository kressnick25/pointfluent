import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static const routeName = '/home';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPracticeApp',
      theme: Theme.of(context),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        body: HomePageOptions(),
      ),
    );
  }
}

class HomePageOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
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
              'Settings',
              style: const TextStyle(
                fontSize: 22,
              ),
            ),
            leading: Icon(Icons.settings),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => Navigator.of(context).pushNamed('/settings'),
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
            onTap: () => Navigator.of(context).popAndPushNamed('/'),
          ),
        ),
      ],
    );
  }
}
