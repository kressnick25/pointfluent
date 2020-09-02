import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  SharedPreferences userPrefs;
  bool _ignoreCert = false;
  bool _isLoading = false;
  bool _rememberMe = false;
  String _errMessage;
  String _intialEmail;
  AuthDetails user = AuthDetails();
  ErrorMsg error;

  @override
  initState() {
    super.initState();
    _rememberMeState();
    _certValState();
  }

  _rememberMeState() async {
    userPrefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = (userPrefs.getBool('rememberme') ?? false);
      _intialEmail = (userPrefs.getString('email') ?? '');
    });
  }

  _certValState() async {
    userPrefs = await SharedPreferences.getInstance();
    setState(() {
      _ignoreCert = (userPrefs.getBool('certval') ?? false);
    });
  }

  _updateRememberMe(bool value) {
    setState(() {
      _rememberMe = !_rememberMe;
    });

    userPrefs.setBool('rememberme', value);

    if (!_rememberMe) {
      userPrefs.remove('email');
    }
  }

  _launchRegisterURL() async {
    const url = Constants.url_udStreamRegister;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchForgotPasswordURL() async {
    const url = Constants.url_udStreamForgotPassword;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _updateCertVal(bool value) {
    setState(() {
      _ignoreCert = !_ignoreCert;
    });

    userPrefs.setBool('certval', value);
  }

  Future<void> onSubmit() async {
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    Future<void> _showAlertDialog(String errorMessage) async {
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

    // bind local state to udConfig state
    UdConfig.ignoreCertificateVerification(_ignoreCert);
    try {
      widget.udContext.connect(user.username, user.password);
      setState(() {
        _errMessage = null;
        _isLoading = false;
      });

      Navigator.popAndPushNamed(
        context,
        '/home',
      );
    } catch (e) {
      setState(() {
        _errMessage = e.toString();
        _isLoading = false;
        // _showAlertDialog(_errMessage);
        error.showAlertDialog(_errMessage, context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent layout from rotating on this screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 50, left: 50, right: 50),
              child: KeyboardVisibilityBuilder(
                builder: (context, child, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? emptyWidget
                      : Image.asset(Constants.img_pointfluentLogo500,
                          height: 200, width: 200);
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: KeyboardVisibilityBuilder(
                builder: (context, child, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? emptyWidget
                      : Image.asset(Constants.img_eu_powered_logo,
                          height: 50, width: 100);
                },
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 30, right: 30, top: 20, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: TextFormField(
                    initialValue: _intialEmail,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Email',
                    ),
                    validator: (value) {
                      return value.isEmpty ? 'Please enter your email.' : null;
                    },
                    onSaved: (String value) {
                      user.username = value;
                      if (_rememberMe) {
                        userPrefs.setString('email', value);
                      }
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, right: 30, bottom: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: new BorderRadius.circular(5.0),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 15, right: 15, top: 5),
                  child: TextFormField(
                    obscureText: true,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Password',
                    ),
                    validator: (value) {
                      return value.isEmpty
                          ? 'Please enter your password.'
                          : null;
                    },
                    onSaved: (String value) {
                      user.password = value;
                    },
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 50,
                  child: CheckboxListTile(
                    title: Text('Remember Me'),
                    controlAffinity: ListTileControlAffinity.leading,
                    value: _rememberMe,
                    onChanged: (bool value) {
                      _updateRememberMe(value);
                    },
                  ),
                ),
                SizedBox(
                  child: ButtonTheme(
                    minWidth: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    child: FlatButton(
                      color: Theme.of(context).backgroundColor,
                      onPressed: _launchForgotPasswordURL,
                      child: Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                child: RaisedButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  onPressed: () async {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState.validate()) {
                      onSubmit();
                    }
                  },
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text(
                          'Login',
                          style: TextStyle(fontSize: 20),
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(),
              child: ButtonTheme(
                minWidth: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.07,
                child: FlatButton(
                  color: Theme.of(context).backgroundColor,
                  onPressed: _launchRegisterURL,
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
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
          ],
        ),
      ),
    );
  }
}
