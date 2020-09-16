import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final Widget trailing;
  final GestureTapCallback onTap;

  MenuItem({this.title, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      color: Colors.white,
      child: ListTile(
        title: Text(
          this.title,
          style: const TextStyle(fontSize: 16, letterSpacing: -0.3),
        ),
        trailing: this.trailing,
        onTap: this.onTap,
      ),
    );
  }
}
