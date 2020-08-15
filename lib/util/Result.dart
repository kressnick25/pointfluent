import 'package:vaultSDK/udError.dart';

abstract class Result<T> {
  T value;
  String message;

  bool get error;
  bool get ok;
  void setErrorMessage();
}

class AuthResult extends Result<udError> {
  udError value;
  String message;

  AuthResult() : super();

  bool get error {
    if (value == null) return false;
    return value != udError.udE_Success;
  }

  bool get ok {
    if (value == null) return false;
    return value == udError.udE_Success;
  }

  // Returns a string representation of the vdkError value
  // without prefixed 'vdkError.'
  String get type {
    String val = value.toString();
    return val.substring(val.lastIndexOf('.')).substring(1);
  }

  void setErrorMessage() {
    switch (this.value) {
      case udError.udE_AuthFailure:
        {
          this.message = "Invalid credentials, please try again.";
        }
        break;

      case udError.udE_SecurityFailure:
        {
          // TODO alert screen with option to change setting
          this.message = "Security failure, try disabling cert verification.";
        }
        break;

      case udError.udE_ProxyError:
        {
          this.message =
              "There was an issue with the provided proxy information.";
        }
        break;

      // Handle more errors here

      default:
        {
          this.message = "An unknown error has occured. Code ${this.type}";
        }
        break;
    }
  }
}
