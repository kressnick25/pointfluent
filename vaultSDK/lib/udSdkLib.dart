import 'dart:io';
import 'dart:ffi';

final DynamicLibrary udSdkLib = Platform.isAndroid
    ? DynamicLibrary.open("libudSDK.so")
    : DynamicLibrary.process();
