import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'udSdkLib.dart';

class UdUserUtil extends UdSDKClass {
  Pointer<IntPtr> _context;

  UdUserUtil() {
    this._context = allocate();
    setMounted();
  }

  // Call these functions in flutter widgets
  void changePassword(newPassword, oldPassword) {
    checkMounted();
    final uOldPassword = Utf8.toUtf8(newPassword);
    final uNewPassword = Utf8.toUtf8(oldPassword);
    var err =
    udUserUtil_ChangePassword(this._context, uNewPassword, uOldPassword);

    free(uNewPassword);
    free(uOldPassword);

    handleUdError(err);
  }

  void destroy() {
    checkMounted();
    this.dispose();
  }

  void dispose() {
    free(this._context);
    super.dispose();
  }
}

typedef udUserUtil_ChangePassword_native = Int32 Function(
    Pointer<IntPtr> context,
    Pointer<Utf8> newPassword,
    Pointer<Utf8> oldPassword);

typedef udUserUtil_ChangePassword_dart = int Function(
    Pointer<IntPtr> context,
    Pointer<Utf8> newPassword,
    Pointer<Utf8> oldPassword);

final udUserUtil_ChangePasswordPointer = udSdkLib
    .lookup<NativeFunction<udUserUtil_ChangePassword_native>>('udUserUtil_ChangePassword');

final udUserUtil_ChangePassword =
  udUserUtil_ChangePasswordPointer.asFunction<udUserUtil_ChangePassword_dart>();