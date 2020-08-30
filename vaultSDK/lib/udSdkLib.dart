import 'dart:io';
import 'dart:ffi';

import 'udError.dart';

final DynamicLibrary udSdkLib = Platform.isAndroid
    ? DynamicLibrary.open("libudSDK.so")
    : DynamicLibrary.process();

abstract class UdSDKClass {
  static final udSdkLibOpen = udSdkLib;

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
}
