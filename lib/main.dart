import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';

import 'auth/login.dart';
import 'auth/home.dart';
import 'auth/settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final udContext = UdContext();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Custom material color data
    Map<int, Color> color = {
      50: Color.fromRGBO(18, 171, 199, .1),
      100: Color.fromRGBO(18, 171, 199, .2),
      200: Color.fromRGBO(18, 171, 199, .3),
      300: Color.fromRGBO(18, 171, 199, .4),
      400: Color.fromRGBO(18, 171, 199, .5),
      500: Color.fromRGBO(18, 171, 199, .6),
      600: Color.fromRGBO(18, 171, 199, .7),
      700: Color.fromRGBO(18, 171, 199, .8),
      800: Color.fromRGBO(18, 171, 199, .9),
      900: Color.fromRGBO(18, 171, 199, 1),
    };

    MaterialColor customColor = MaterialColor(0xff12abc7, color);

    return MaterialApp(
        title: 'Flutter Demo',
        //Set to true to display the debug banner in build mode
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: customColor,
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
