# Pointfluent

Point cloud rendering on mobile using Euclideon's udSDK.

## Getting Started

Install flutter -> [instructions](https://flutter.dev/docs/get-started/install)

Download Euclideon's [udSDK](https://www.euclideon.com/udsdk/)

Copy all header files from `udkSDK/include` into `vaultSDK/ios/Classes/`

### Android
- Copy the `android_arm64` and `android_x64` folders from `udSDK/lib/` into a new folder `vaultSDK/android/src/main/jniLibs`. 
- Rename them to `arm64-v8a` and `x86_64` respectively.

### iOS
 - TODO

 Build & run the project using `flutter run`

## Code Style
See [Effective Dart: Style](https://dart.dev/guides/language/effective-dart/style)
