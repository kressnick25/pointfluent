import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ErrorMsg {
  String message;
  ErrorMsg({this.message});

  Future<void> showAlertDialog(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(this.message),
            actions: <Widget>[
              FlatButton(
                child: Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }
}
