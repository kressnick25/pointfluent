#ifndef vdkError_h__
#define vdkError_h__

//! @file vdkError.h
//! These are the shared return codes from most VDK functions

#ifdef __cplusplus
extern "C" {
#endif

//!
//! These are the various error codes returned by VDK functions
//! @note The `0` value is success, this is different to many C APIs and as such `if(vdkFunction() == vE_Success)` is required to handle success cases.
//!
enum vdkError
{
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
};

#ifdef __cplusplus
}
#endif

#endif // vdkError_h__
