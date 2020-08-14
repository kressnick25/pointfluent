import 'dart:ffi';

import 'vdkLib.dart';
import 'udError.dart';

class UdConfig {
  // static const MethodChannel _channel = const MethodChannel('udContext');

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }

  // Call these functions in flutter widgets

  // Allows VDK to connect to server with an unrecognized certificate authority, sometimes required for self-signed certificates or poorly configured proxies.
  // Used for workaround where calling UdContext.connect will always return vE_SecurityFailure
  static udError ignoreCertificateVerification(bool ignore) {
    // Cast boolean to C int where 0 == False and 1 == True
    int ignoreVal = ignore ? 1 : 0;
    var err = udConfig_IgnoreCertificateVerification(ignoreVal);

    return udError.values[err];
  }
}

typedef udConfig_IgnoreCertificateVerification_native = Int32 Function(
    Int32 ignore);
typedef udConfig_IgnoreCertificateVerification_dart = int Function(int ignore);

final udConfig_IgnoreCertificateVerificationPointer = vdkLib
    .lookup<NativeFunction<udConfig_IgnoreCertificateVerification_native>>(
        'udConfig_IgnoreCertificateVerification');

final udConfig_IgnoreCertificateVerification =
    udConfig_IgnoreCertificateVerificationPointer
        .asFunction<udConfig_IgnoreCertificateVerification_dart>();
