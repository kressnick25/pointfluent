#import "VaultSDKPlugin.h"
#if __has_include(<vaultSDK/vaultSDK-Swift.h>)
#import <vaultSDK/vaultSDK-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vaultSDK-Swift.h"
#endif

@implementation VaultSDKPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVaultSDKPlugin registerWithRegistrar:registrar];
}
@end
