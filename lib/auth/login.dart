import 'dart:ffi';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udConfig.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../util/Constants.dart' as Constants;
import '../widgets/emptyWidget.dart';
import '../widgets/KeyboardVisibilityBuilder.dart';
import '../widgets/ErrorMsg.dart';

class AuthDetails {
  String username;
  String password;

  AuthDetails({this.username, this.password});
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.udContext}) : super(key: key);

  static const routeName = '/';
  final UdContext udContext;
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _ignoreCert = false;
  bool _isLoading = false;
  String _errMessage;
  AuthDetails user = AuthDetails();

  void onSubmit() {
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    // bind local state to udConfig state
    UdConfig.ignoreCertificateVerification(_ignoreCert);
    try {
      widget.udContext.connect(user.username, user.password);
      setState(() {
        _errMessage = null;
        _isLoading = false;
      });

      // TODO set global udContext
      // use popAndPush to stop user pressing back to get to login screen
      Navigator.popAndPushNamed(
        context,
        '/home',
      );
    } catch (e) {
      setState(() {
        _errMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  _launchUrl() async {
    const url = Constants.url_udStreamRegister;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launc $url';
    }
  }

  _updateCertVal(bool newVal) {
    setState(() {
      _ignoreCert = !_ignoreCert;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prevent layout from rotating on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            KeyboardVisibilityBuilder(
                builder: (context, child, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? emptyWidget
                      : Image.asset(Constants.img_pointfluentLogo500,
                          height: 300, width: 300);
                },
                child: Image.asset(Constants.img_pointfluentLogo500)),
            TextFormField(
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
              validator: (value) {
                return value.isEmpty ? 'Please enter your email' : null;
              },
              onSaved: (String value) {
                user.username = value;
              },
            ),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              validator: (value) {
                return value.isEmpty ? 'Please enter your password' : null;
              },
              onSaved: (String value) {
                user.password = value;
              },
            ),
            SizedBox(
              width: 500,
              height: 50,
              child: CheckboxListTile(
                  title: Text('Ignore Certificate Security'),
                  controlAffinity: ListTileControlAffinity.leading,
                  value: _ignoreCert,
                  onChanged: (bool value) {
                    _updateCertVal(value);
                  }),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: () {
                  // Validate will return true if the form is valid, or false if
                  // the form is invalid.
                  if (_formKey.currentState.validate()) {
                    onSubmit();
                  }
                },
                child:
                    _isLoading ? CircularProgressIndicator() : Text('Submit'),
              ),
            ),
            ErrorMsg(message: _errMessage),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RaisedButton(
                onPressed: _launchUrl,
                child: new Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
