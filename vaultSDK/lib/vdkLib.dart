import 'dart:io';
import 'dart:ffi';

final DynamicLibrary vdkLib = Platform.isAndroid
    ? DynamicLibrary.open("libvaultSDK.so")
    : DynamicLibrary.process();
