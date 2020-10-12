import 'package:Pointfluent/util/SlidePageRoute.dart';
import 'package:Pointfluent/widgets/RecentModels.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udManager.dart';
import 'package:provider/provider.dart';

import 'auth/login.dart';
import 'auth/home.dart';
import 'auth/settings.dart';
import 'auth/sceneViewer.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => RecentModelsData(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final udContext = UdContext();
  final udManager = UdManager();

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
          scaffoldBackgroundColor:
              Color(0xfff8f8f8), // background color for menu
          fontFamily: 'Roboto',
        ),
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case LoginPage.routeName:
              return SlidePageRoute(builder: (context) => LoginPage(udManager: udManager,), settings: settings);
              break;
            case HomePage.routeName:
              return SlidePageRoute(builder: (context) => HomePage(udManager: udManager,), settings: settings);
              break;
            case SceneViewerPage.routeName:
              return SlidePageRoute(
                  builder: (context) =>
                      SceneViewerPage(udManager: udManager,), settings: settings);
              break;
            case SettingsPage.routeName:
              return SlidePageRoute(builder: (context) => SettingsPage(), settings: settings);
              break;
          }
        });
  }
}
