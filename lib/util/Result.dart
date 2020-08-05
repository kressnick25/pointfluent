import 'package:vaultSDK/udError.dart';

abstract class Result<T> {
  T value;
  String message;

  bool get error;
  bool get ok;
  void setErrorMessage();
}

class AuthResult extends Result<vdkError> {
  vdkError value;
  String message;

  AuthResult() : super();

  bool get error {
    if (value == null) return false;
    return value != vdkError.vE_Success;
  }

  bool get ok {
    if (value == null) return false;
    return value == vdkError.vE_Success;
  }

  void setErrorMessage() {
    switch (this.value) {
      case vdkError.vE_AuthFailure:
        {
          this.message = "Invalid credentials, please try again.";
        }
        break;

      case vdkError.vE_SecurityFailure:
        {
          // TODO alert screen with option to change setting
          this.message = "Security failure, try disabling cert verification.";
        }
        break;

      case vdkError.vE_ProxyError:
        {
          this.message =
              "There was an issue with the provided proxy information.";
        }
        break;

      // Handle more errors here

      default:
        {
          this.message = "An unknown error has occured.";
        }
        break;
    }
  }
}
