#ifndef vdkContext_h__
#define vdkContext_h__

//! @file vdkContext.h
//! The **vdkContext** object provides an interface to connect and communicate with a Euclideon Vault server.
//! Once instantiated, the **vdkContext** can be passed into many VDK functions to provide a context to operate within.

#include "vdkDLLExport.h"
#include "vdkError.h"
#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

//!
//! @struct vdkContext
//! Stores the internal state of the VDK system
//!
struct vdkContext;

//!
//! These are the various license types used throughout VDK
//!
enum vdkLicenseType
{
  vdkLT_Render, //!< Allows access to the rendering and model modules
  vdkLT_Convert, //!< Allows access to convert models to a UD model

  vdkLT_Count //!< Total number of license types. Used internally but can be used as an iterator max when checking license information.
};

//!
//! This structure stores information about the current session
//!
struct vdkSessionInfo
{
  double expiresTimestamp; //!< The timestamp in UTC when the session will automatically end
  char displayName[1024]; //!< The null terminated display name of the user
};

//!
//! This structure stores information about the license check-out status
//!
struct vdkLicenseInfo
{
  int64_t queuePosition; //!< The status of the license and the queue position if known. { -1 = Have License, 0 = Not In Queue, >0 is Queue Position }

  uint64_t expiresTimestamp; //!< The timestamp in UTC when the license checkout expires
};

//!
//! Establishes a connection to a Euclideon Vault server and creates a new vdkContext object.
//!
//! @param ppContext A pointer to a location in which the new vdkContext object is stored.
//! @param pURL A URL to a Euclideon Vault server to connect to.
//! @param pApplicationName The name of the application connecting to the Euclideon Vault server.
//! @param pUsername The username of the user connecting to the Euclideon Vault server.
//! @param pPassword The password of the user connecting to the Euclideon Vault server.
//! @return A vdkError value based on the result of the connection creation.
//! @warning If `NULL` is passed in for both `pUsername` and `pPassword`, a guest session will attempt to be created if the server supports it.
//! @note The application should call **vdkContext_Disconnect** with `ppContext` to destroy the object once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkContext_Connect(struct vdkContext **ppContext, const char *pURL, const char *pApplicationName, const char *pUsername, const char *pPassword);

//!
//! Attempts to reestablish a connection to a Euclideon Vault server (or run offline with an offline context) and creates a new vdkContext object.
//!
//! @param ppContext A pointer to a location in which the new vdkContext object is stored.
//! @param pURL A URL to a Euclideon Vault server to connect to.
//! @param pApplicationName The name of the application connecting to the Euclideon Vault server.
//! @param pUsername The username of the user connecting to the Euclideon Vault server.
//! @param tryDongle If false, the dongle will not be checked (on platforms that support dongles).
//! @return A vdkError value based on the result of the connection creation.
//! @warning The application should call vdkContext_Disconnect with `ppContext` to destroy the object once it's no longer needed.
//! @warning This function can crash with some debuggers attached when trying to read from a dongle. If debugging, ensure that tryDongle is set to false.
//! @note This function will try use a session from a dongle first if that is supported; passing null to pURL, pApplicationName and pUsername will test the dongle but will otherwise be invalid
//!
VDKDLL_API enum vdkError vdkContext_TryResume(struct vdkContext **ppContext, const char *pURL, const char *pApplicationName, const char *pUsername, bool tryDongle);

//!
//! Disconnects and destroys a vdkContext object that was created using **vdkContext_Connect**.
//!
//! @param ppContext A pointer to a vdkContext object which is to be disconnected and destroyed.
//! @return A vdkError value based on the result of the connection destruction. 
//! @note The value of `ppContext` will be set to `NULL`.
//! @warning If other resources are still referencing this context this will return vE_NotAllowed until those resources are destroyed first
//!
VDKDLL_API enum vdkError vdkContext_Disconnect(struct vdkContext **ppContext);

//!
//! Attempts to claim a license from the Euclideon Vault Server with which `pContext` is connected.
//!
//! @param pContext The context which will be used to claim the license.
//! @param licenseType Describes the type of license to be claimed.
//! @return A vdkError value based on the result of the license request.
//!
VDKDLL_API enum vdkError vdkContext_RequestLicense(struct vdkContext *pContext, enum vdkLicenseType licenseType);

//!
//! Attempts to renew a license from the Euclideon Vault Server with which `pContext` is connected.
//!
//! @param pContext The context which will be used to renew the license.
//! @param licenseType Describes the type of license to be claimed.
//! @return A vdkError value based on the result of the license request.
//!
VDKDLL_API enum vdkError vdkContext_RenewLicense(struct vdkContext *pContext, enum vdkLicenseType licenseType);

//!
//! Checks the status of the specified license to which `pContext` has claimed from the Euclideon Vault Server.
//!
//! @param pContext The context that has claimed the specified license type.
//! @param licenseType The type of license to be checked.
//! @return A vdkError value based on the result of the license check.
//! @note The application can claim licenses by calling **vdkContext_RequestLicense**. **vdkContext_CheckLicense** can then be called to check the licenses to which a vdkContext has access.
//!
VDKDLL_API enum vdkError vdkContext_CheckLicense(struct vdkContext *pContext, enum vdkLicenseType licenseType);

//!
//! Get the information from the `pContext` for the type of license specified.
//!
//! @param pContext The context that has claimed the specified license type.
//! @param licenseType The type of license to be retrieved.
//! @param pInfo The information related to the specified type of license.
//! @return A vdkError value based on the result of getting the license.
//! @note This function will return vE_Success and `queuePosition` in `pInfo` will be `0` if no license was previously obtained but VDK is negotiating to be in queue.
//!
VDKDLL_API enum vdkError vdkContext_GetLicenseInfo(struct vdkContext *pContext, enum vdkLicenseType licenseType, struct vdkLicenseInfo *pInfo);

//!
//! Get the session information from an active vdkContext.
//!
//! @param pContext The vdkContext to get the session info for.
//! @param pInfo The preallocated structure to copy the info into.
//! @return A vdkError value based on the result of copying the structure
//!
VDKDLL_API enum vdkError vdkContext_GetSessionInfo(struct vdkContext *pContext, struct vdkSessionInfo *pInfo);

//!
//! Ensures a vdkContext object does not expire on the server.
//!
//! @param pContext A pointer to the vdkContext object that is intended to be kept alive.
//! @return A vdkError value based on the result of keeping the object alive.
//!
VDKDLL_API enum vdkError vdkContext_KeepAlive(struct vdkContext *pContext);

#ifdef __cplusplus
}
#endif

#endif // vdkContext_h__
