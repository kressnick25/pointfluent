import 'package:Pointfluent/widgets/menuItem.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).backgroundColor,
      backgroundColor: Color(0xfff8f8f8),
      appBar: AppBar(
        leading:IconButton(
          icon: Icon(Icons.keyboard_arrow_left, color: Colors.white, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 80,
        elevation: 0,
        title:
        Text('Settings', style: TextStyle(color: Colors.white, fontSize: 26)),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 15, 0, 9),
            child: Text(
              'Account',
              style: const TextStyle(
                color: Color(0xff919191),
                fontSize: 14
              )
            )
          ),
          MenuItem(
            title: 'Change Email',
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => null,
            margin: const EdgeInsets.only(top: 0),),
          MenuItem(
            title: 'Change Password',
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () => null,
            margin: const EdgeInsets.only(top: 1),),
        ],
      ),
    );
  }
}
