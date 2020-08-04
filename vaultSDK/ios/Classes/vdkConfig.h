#ifndef vdkConfig_h__
#define vdkConfig_h__

//! @file vdkConfig.h
//! The **vdkConfig** functions all set global configuration options for the entire loaded shared library.

#include "vdkDLLExport.h"
#include "vdkError.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//!
//! This function can be used to override the internal proxy auto-detection used by cURL.
//!
//! @param pProxyAddress This is a null terminated string, can include port number and protocol. `192.168.0.1`, `169.123.123.1:80`, `https://10.4.0.1:8081` or `https://proxy.example.com`. Setting this to either `NULL` or (empty string) `""` will reset to attempting auto-detection.
//! @return A vdkError value based on the result of forcing the proxy.
//! @note By default the proxy is attempted to be auto-detected. This fails in many proxy configurations.
//!
VDKDLL_API enum vdkError vdkConfig_ForceProxy(const char *pProxyAddress);

//!
//! This function is used in conjunction with `vdkConfig_ForceProxy` or the auto-detect proxy system to forward info from the user for their proxy details.
//!
//! @param pProxyUsername This is a null terminated string of the username of the user for the proxy.
//! @param pProxyPassword This is a null terminated string of the password of the user for the proxy.
//! @return A vdkError value based on the result of setting the proxy authentication.
//! @note This is usually called after another VDK function returns `vE_ProxyAuthRequired`.
//!
VDKDLL_API enum vdkError vdkConfig_SetProxyAuth(const char *pProxyUsername, const char *pProxyPassword);

//!
//! Allows VDK to connect to server with an unrecognized certificate authority, sometimes required for self-signed certificates or poorly configured proxies.
//!
//! @param ignore `true` if certificate verification should be skipped or `false` if verification is to be processed.
//! @return A vdkError value based on the result of ignoring the certificate verification.
//! @warning Ignoring certificate verification is very high risk. Do not enable this option by default and display clearly to the user that this setting will reduce the security of the entire system and they should only enable the setting if their system administrator has instructed them to do so.
//! @note By default certificate verification is run (not ignored).
//!
VDKDLL_API enum vdkError vdkConfig_IgnoreCertificateVerification(bool ignore);

//!
//! This function can be used to override the user agent used by cURL.
//!
//! @param pUserAgent This is a null terminated string of the user agent.
//! @return A vdkError value based on the result of setting the user agent.
//!
VDKDLL_API enum vdkError vdkConfig_SetUserAgent(const char *pUserAgent);

#ifdef __cplusplus
}
#endif

#endif // vdkConfig_h__
