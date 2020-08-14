import 'dart:io';
import 'dart:ffi';

final DynamicLibrary vdkLib = Platform.isAndroid
    ? DynamicLibrary.open("libudSDK.so")
    : DynamicLibrary.process();
