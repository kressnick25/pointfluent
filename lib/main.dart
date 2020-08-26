import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udError.dart';
import 'package:flutter/foundation.dart';

import 'auth/login.dart';
import 'auth/home.dart';
import 'auth/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static Pointer<IntPtr> udContext = allocate();
  static invalidCode;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/',
        routes: {
          LoginPage.routeName: (context) => LoginPage(
                udContext: udContext,
              ),
          HomePage.routeName: (context) => HomePage(),
          SettingsPage.routeName: (context) => SettingsPage(),
        });
  }
}
