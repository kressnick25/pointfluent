import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'package:flutter/services.dart';

class VaultSDK {
  static const MethodChannel _channel = const MethodChannel('vaultSDK');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}

final DynamicLibrary vaultSDKlib = Platform.isAndroid
    ? DynamicLibrary.open("libvaultSDK.so")
    : DynamicLibrary.process();

typedef udContext_Connect_native = Int32 Function(
    Pointer<IntPtr> context,
    Pointer<Utf8> url,
    Pointer<Utf8> applicationName,
    Pointer<Utf8> email,
    Pointer<Utf8> password);
typedef udContext_Connect_dart = int Function(
    Pointer<IntPtr> context,
    Pointer<Utf8> url,
    Pointer<Utf8> applicationName,
    Pointer<Utf8> email,
    Pointer<Utf8> password);

final udContext_ConnectPointer = vaultSDKlib
    .lookup<NativeFunction<udContext_Connect_native>>('udContext_Connect');

final udContext_Connect =
    udContext_ConnectPointer.asFunction<udContext_Connect_dart>();
