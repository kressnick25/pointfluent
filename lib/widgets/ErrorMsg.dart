import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ErrorMsg extends StatelessWidget {
  final String message;

  ErrorMsg({this.message});

  @override
  Widget build(BuildContext context) {
    return Text(this.message ?? '', style: TextStyle(color: Colors.red));
  }
}
