import 'dart:async';
import 'dart:ffi';
import 'dart:web_gl';

import 'package:ffi/ffi.dart';

import 'udSdkLib.dart';
import 'udError.dart';

class UdContext {
  Pointer<IntPtr> _context;

  UdContext() {
    this._context = allocate();
  }

  get address => this._context;

  // Call these functions in flutter widgets
  udError connect(email, password,
      [url = 'https://udstream.euclideon.com', appName = 'Pointfluent']) {
    final uUrl = Utf8.toUtf8(url);
    final uAppName = Utf8.toUtf8(appName);
    final uEmail = Utf8.toUtf8(email);
    final uPassword = Utf8.toUtf8(password);
    var err =
        udContext_Connect(this._context, uUrl, uAppName, uEmail, uPassword);

    free(uUrl);
    free(uAppName);
    free(uEmail);
    free(uPassword);

    return udErrorValue(err);
  }

  /// Disconnects and destroys a udContext object that was created using connect
  ///
  /// endSession ends the session entirely and cannot be resumed
  udError disconnect({bool endSession = true}) {
    int endSessionVal = endSession ? 1 : 0;
    final err = udContext_Disconnect(this._context, endSessionVal);

    this._cleanup();
    return udErrorValue(err);
  }

  void _cleanup() {
    free(this._context);
  }
}

// C BINDING DEFINITIONS
// udContext_Connect
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

final udContext_ConnectPointer = udSdkLib
    .lookup<NativeFunction<udContext_Connect_native>>('udContext_Connect');

final udContext_Connect =
    udContext_ConnectPointer.asFunction<udContext_Connect_dart>();

// udContext_Disconnect
typedef udContext_Disconnect_native = Int32 Function(
  Pointer<IntPtr> context,
  Uint32 endSession,
);
typedef udContext_Disconnect_dart = int Function(
  Pointer<IntPtr> context,
  int endSession,
);
final udContext_DisconnectPointer =
    udSdkLib.lookup<NativeFunction<udContext_Disconnect_native>>(
        'udContext_Disconnect');
final udContext_Disconnect =
    udContext_DisconnectPointer.asFunction<udContext_Disconnect_dart>();
