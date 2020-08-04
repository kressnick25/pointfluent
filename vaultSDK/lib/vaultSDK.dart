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

// vdk Structures
class vdkContext extends Struct {}

// various license types used throughout vdk
enum vdkLicenseType {
  vdkLT_Render, //!< Allows access to the rendering and model modules
  vdkLT_Convert, //!< Allows access to convert models to a UD model

  vdkLT_Count //!< Total number of license types. Used internally but can be used as an iterator max when checking license information.
}

// Stores information about the current session
class vdkSessionInfo extends Struct
{
  @Double()
  double expiresTimestamp; //!< The timestamp in UTC when the session will automatically end

  @
  char displayName[1024]; //!< The null terminated display name of the user
};
enum vdkError {
  vE_Success, //!< Indicates the operation was successful

  vE_Failure, //!< A catch-all value that is rarely used, internally the below values are favored
  vE_InvalidParameter, //!< One or more parameters is not of the expected format
  vE_InvalidConfiguration, //!< Something in the request is not correctly configured or has conflicting settings
  vE_InvalidLicense, //!< The required license isn't available or has expired
  vE_SessionExpired, //!< The Vault Server has terminated your session

  vE_NotAllowed, //!< The requested operation is not allowed (usually this is because the operation isn't allowed in the current state)
  vE_NotSupported, //!< This functionality has not yet been implemented (usually some combination of inputs isn't compatible yet)
  vE_NotFound, //!< The requested item wasn't found or isn't currently available
  vE_NotInitialized, //!< The request can't be processed because an object hasn't been configured yet

  vE_ConnectionFailure, //!< There was a connection failure
  vE_MemoryAllocationFailure, //!< VDK wasn't able to allocate enough memory for the requested feature
  vE_ServerFailure, //!< The server reported an error trying to fufil the request
  vE_AuthFailure, //!< The provided credentials were declined (usually username or password issue)
  vE_SecurityFailure, //!< There was an issue somewhere in the security system- usually creating or verifying of digital signatures or cryptographic key pairs
  vE_OutOfSync, //!< There is an inconsistency between the internal VDK state and something external. This is usually because of a time difference between the local machine and a remote server

  vE_ProxyError, //!< There was some issue with the provided proxy information (either a proxy is in the way or the provided proxy info wasn't correct)
  vE_ProxyAuthRequired, //!< A proxy has requested authentication

  vE_OpenFailure, //!< A requested resource was unable to be opened
  vE_ReadFailure, //!< A requested resourse was unable to be read
  vE_WriteFailure, //!< A requested resource was unable to be written
  vE_ParseError, //!< A requested resource or input was unable to be parsed
  vE_ImageParseError, //!< An image was unable to be parsed. This is usually an indication of either a corrupt or unsupported image format

  vE_Pending, //!< A requested operation is pending.
  vE_TooManyRequests, //!< This functionality is currently being rate limited or has exhausted a shared resource. Trying again later may be successful
  vE_Cancelled, //!< The requested operation was cancelled (usually by the user)

  vE_Count //!< Internally used to verify return values
}

final int Function(int x, int y) nativeAdd = nativeAddLib
    .lookup<NativeFunction<Int32 Function(Int32, Int32)>>("native_add")
    .asFunction();

final int Function(
        Pointer<vdkContext> context,
        Pointer<Utf8> url,
        Pointer<Utf8> applicationName,
        Pointer<Utf8> username,
        Pointer<Utf8> password) vdkContext_Connect =
    vaultSDKlib
        .lookup<
            NativeFunction<
                Int32 Function(Pointer, Pointer, Pointer, Pointer,
                    Pointer)>>("vdkContext_Connect")
        .asFunction();
