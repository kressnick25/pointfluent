import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ErrorMsg {
  final String message;
  ErrorMsg({this.message});

  Future<void> showAlertDialog(
      String errorMessage, BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(errorMessage),
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
