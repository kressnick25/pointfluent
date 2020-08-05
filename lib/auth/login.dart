import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';

import '../util/Result.dart';

class AuthDetails {
  String username;
  String password;

  AuthDetails({this.username, this.password});
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.vdkContext}) : super(key: key);

  static const routeName = '/';
  final Pointer<IntPtr> vdkContext;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  AuthResult _authResult = AuthResult();
  AuthDetails user = AuthDetails();

  void onSubmit() {
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    final err =
        UdContext.connect(widget.vdkContext, user.username, user.password);

    setState(() {
      _isLoading = false;
      _authResult.value = err;
    });

    if (_authResult.ok) {
      // TODO set global context
      // Provide user details to next screen
      Navigator.pushNamed(context, '/home',
          arguments:
              AuthDetails(username: user.username, password: user.password));
    } else {
      _authResult.setErrorMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Email or Username',
                ),
                validator: (value) {
                  return value.isEmpty ? 'Please enter your username' : null;
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
              Text(_authResult.error ? _authResult.message : '',
                  style: TextStyle(color: Colors.red))
            ],
          ),
        ),
      ),
    );
  }
}
