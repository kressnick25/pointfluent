import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/Result.dart';

class AuthDetails {
  String username;
  String password;

  AuthDetails({this.username, this.password});
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  static const routeName = '/';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  Result _authResult = Result();
  AuthDetails user = AuthDetails();

  // TODO Call vdkCreateContext here when implemneted
  Future<int> mock_vdkCreateContext(String username, String password) {
    return Future.delayed(const Duration(milliseconds: 1000), () => 0);
  }

  void onSubmit() async {
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    final res = await mock_vdkCreateContext(user.username, user.password);
    setState(() {
      _isLoading = false;
      _authResult.value = res;
    });
    if (_authResult.ok) {
      // TODO set global context
      // Provide user details to next screen
      Navigator.pushNamed(context, '/home',
          arguments:
              AuthDetails(username: user.username, password: user.password));
    } else {
      _authResult.message = 'Details were incorrect, please try again.';
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
