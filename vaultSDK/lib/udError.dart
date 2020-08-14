/// These are the various error codes returned by udSDK functions
///
/// The `0` value is success, this is different to many C APIs and as such `if(udFunction() == udE_Success)` is required to handle success cases.
enum udError {
  udE_Success, //!< Indicates the operation was successful

  udE_Failure, //!< A catch-all value that is rarely used, internally the below values are favored
  udE_InvalidParameter, //!< One or more parameters is not of the expected format
  udE_InvalidConfiguration, //!< Something in the request is not correctly configured or has conflicting settings
  udE_InvalidLicense, //!< The required license isn't available or has expired
  udE_SessionExpired, //!< The udServer has terminated your session

  udE_NotAllowed, //!< The requested operation is not allowed (usually this is because the operation isn't allowed in the current state)
  udE_NotSupported, //!< This functionality has not yet been implemented (usually some combination of inputs isn't compatible yet)
  udE_NotFound, //!< The requested item wasn't found or isn't currently available
  udE_NotInitialized, //!< The request can't be processed because an object hasn't been configured yet

  udE_ConnectionFailure, //!< There was a connection failure
  udE_MemoryAllocationFailure, //!< udSDK wasn't able to allocate enough memory for the requested feature
  udE_ServerFailure, //!< The server reported an error trying to fufil the request
  udE_AuthFailure, //!< The provided credentials were declined (usually email or password issue)
  udE_SecurityFailure, //!< There was an issue somewhere in the security system- usually creating or verifying of digital signatures or cryptographic key pairs
  udE_OutOfSync, //!< There is an inconsistency between the internal udSDK state and something external. This is usually because of a time difference between the local machine and a remote server

  udE_ProxyError, //!< There was some issue with the provided proxy information (either a proxy is in the way or the provided proxy info wasn't correct)
  udE_ProxyAuthRequired, //!< A proxy has requested authentication

  udE_OpenFailure, //!< A requested resource was unable to be opened
  udE_ReadFailure, //!< A requested resourse was unable to be read
  udE_WriteFailure, //!< A requested resource was unable to be written
  udE_ParseError, //!< A requested resource or input was unable to be parsed
  udE_ImageParseError, //!< An image was unable to be parsed. This is usually an indication of either a corrupt or unsupported image format

  udE_Pending, //!< A requested operation is pending.
  udE_TooManyRequests, //!< This functionality is currently being rate limited or has exhausted a shared resource. Trying again later may be successful
  udE_Cancelled, //!< The requested operation was cancelled (usually by the user)
  udE_Timeout, //!< The requested operation timed out. Trying again later may be successful
  udE_OutstandingReferences, //!< The requested operation failed because there are still references to this object
  udE_ExceededAllowedLimit, //!< The requested operation failed because it would exceed the allowed limits (generally used for exceeding server limits like number of projects)

  udE_Count //!< Internally used to verify return values
}
