import 'package:Pointfluent/widgets/emptyWidget.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String title;
  final Widget trailing;
  final GestureTapCallback onTap;
  final EdgeInsetsGeometry margin;
  final Widget child;
  final bool isLoading;

  MenuItem(
      {this.title,
      this.trailing,
      this.onTap,
      this.margin,
      this.child,
      bool isLoading})
      : this.isLoading = isLoading ?? false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: this.margin,
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            title: Text(
              this.title,
              style: const TextStyle(fontSize: 16, letterSpacing: -0.3),
            ),
            trailing:
                this.isLoading ? CircularProgressIndicator() : this.trailing,
            onTap: this.onTap,
          ),
          this.child ?? emptyWidget,
        ],
      ),
    );
  }
}
