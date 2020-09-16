import 'dart:io';
import 'dart:ffi';

import 'udError.dart';

import 'package:meta/meta.dart';

final DynamicLibrary udSdkLib = Platform.isAndroid
    ? DynamicLibrary.open("libudSDK.so")
    : DynamicLibrary.process();

abstract class UdSDKClass {
  static final udSdkLibOpen = udSdkLib;
  bool _mounted;

  void handleUdError(int resVal) {
    final udErrorVal = udErrorValue(resVal);
    if (udErrorVal != udError.udE_Success) {
      throw new UdException(udErrorVal);
    }
  }

  static void handleUdErrorStatic(int resVal) {
    final udErrorVal = udErrorValue(resVal);
    if (udErrorVal != udError.udE_Success) {
      throw new UdException(udErrorVal);
    }
  }

  void setMounted() => this._mounted = true;

  void checkMounted() {
    try {
      assert(_mounted);
    } catch (err) {
      throw Exception(
          "dispose() has already been called on this udSDK object.");
    }
  }

  @protected
  @mustCallSuper
  void dispose() {
    this._mounted = false;
  }
}
