import 'dart:developer';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udConfig.dart';

import 'package:vaultSDK/udError.dart';
import 'package:flutter/foundation.dart';

import 'auth/login.dart';
import 'auth/home.dart';
import 'auth/settings.dart';

const List<double> cameraMatrix = [
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  5,
  -75,
  5,
  1
];

void main() {
  final width = 640;
  final height = 480;
  final username = "kressnick25@gmail.com";
  final password = "Gizzhead12";
  final modelName = "https://models.euclideon.com/DirCube.uds";

  final udContext = UdContext();
  final renderContext = UdRenderContext();
  final renderTarget = UdRenderTarget(width * height);
  final pointCloud = UdPointCloud();

  UdConfig.ignoreCertificateVerification(true);
  udContext.connect(username, password);

  renderContext.create(udContext);

  renderTarget.create(udContext, renderContext, width, height);

  pointCloud.load(udContext, modelName);
  renderContext.renderInstance.pPointCloud =
      pointCloud.address.cast<udPointCloud>();

  renderContext.renderInstance.setMatrix(cameraMatrix);

  // Sometimes this throws udE_InvalidParameter, sometimes segfaults, sometimes is fine
  renderTarget.setMatrix(udRenderTargetMatrix.udRTM_Camera, cameraMatrix);
  renderContext.renderSettings.flags =
      udRenderContextFlags.udRCF_BlockingStreaming;

  try {
    // This segfaults most times, sometimes returns udE_SessionExpired
    renderContext.render(renderTarget, 1);
  } catch (e) {
    log(e.toString());
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final udContext = UdContext();

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
          HomePage.routeName: (context) => HomePage(
                udContext: udContext,
              ),
          SettingsPage.routeName: (context) => SettingsPage(),
        });
  }
}
