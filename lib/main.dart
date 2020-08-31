import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udError.dart';
import 'package:flutter/foundation.dart';

import 'auth/login.dart';
import 'auth/home.dart';
import 'auth/settings.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final udContext = UdContext();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        //Set to true to display the debug banner in build mode
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          backgroundColor: Colors.white,
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        routes: {
          LoginPage.routeName: (context) => LoginPage(
                udContext: udContext,
              ),
          HomePage.routeName: (context) => HomePage(
                udContext: udContext,
              ),
          SettingsPage.routeName: (context) => SettingsPage(),
        });
  }
}
