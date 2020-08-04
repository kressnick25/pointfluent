#ifndef vdkWeb_h__
#define vdkWeb_h__

//! @file vdkWeb.h
//! This is an optional helper module to assist with doing web requests. Internally it uses libcURL with the global settings (proxy and certificates information) from `vdkConfig`.
//! As this is not a core module, it does not accept a `vdkContext` and can be used without having a Vault Server available.

#include <stdint.h>
#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

  //!
  //! These are the support HTTP method types in vdkWeb
  //!
  enum vdkWebMethod
  {
    vdkWM_HEAD = 0x0,  //!< Performs a HEAD request
    vdkWM_GET = 0x1, //!< Performs a GET request
    vdkWM_POST = 0x2, //!< Performs a POST request
  };

  //!
  //! This structure stores the options for a vdkWeb request
  //!
  //! @note The default values for the members except `method` is `NULL` or `0`.
  //!
  struct vdkWebOptions
  {
    enum vdkWebMethod method; //!< The HTTP method to use for the request.
    const uint8_t *pPostData; //!< The data to send to the server as part of a POST request.
    uint64_t postLength; //!< The length of the data being sent to the server.
    uint64_t rangeBegin; //!< The position of the first byte in the requested file to receive data from.
    uint64_t rangeEnd; //!< The position of the last byte in the requested file to receive data from.
    const char *pAuthUsername; //!< The username to use when authenticating with the server.
    const char *pAuthPassword; //!< The password to use when authenticating with the server.
  };

  //!
  //! This sends a GET request to a given URL, the response (if any) is written to `ppResponse`.
  //!
  //! @param pURL The URL to request.
  //! @param ppResponse This will be modified with a pointer to internal VDK memory with the contents of the request. You must call `vdkWeb_ReleaseResponse` to free this memory.
  //! @param pResponseLength If non-null, the pointer's memory will be set to the length of `ppResponse`.
  //! @param pHTTPResponseCode If non-null this will be set to the HTTP status code. See https ://www.ietf.org/assignments/http-status-codes/http-status-codes.xml for status codes.
  //! @result A vdkError value based on the result of the HTTP request.
  //! @note This function internally just calls `vdkWeb_RequestAdv` with the option members being zeroed, except for the method which is set to `vdkWM_GET`.
  //!
  VDKDLL_API enum vdkError vdkWeb_Request(const char *pURL, const char **ppResponse, uint64_t *pResponseLength, int *pHTTPResponseCode);

  //!
  //! This sends a request to a given URL using the specified options, the response (if any) is written to `ppResponse`.
  //!
  //! @param pURL The URL to request.
  //! @param options The options for the request, see above for details.
  //! @param ppResponse This will be modified with a pointer to internal VDK memory with the contents of the request. You must call `vdkWeb_ReleaseResponse` to free this memory.
  //! @param pResponseLength If non-null, the pointer's memory will be set to the length of `ppResponse`.
  //! @param pHTTPResponseCode If non-null this will be set to the HTTP status code. See https ://www.ietf.org/assignments/http-status-codes/http-status-codes.xml for status codes.
  //! @result A vdkError value based on the result of the HTTP request.
  //!
  VDKDLL_API enum vdkError vdkWeb_RequestAdv(const char *pURL, struct vdkWebOptions options, const char **ppResponse, uint64_t *pResponseLength, int *pHTTPResponseCode);

  //!
  //! Frees memory of a prior call to vdkWeb_Load.
  //!
  //! @param ppResponse A pointer to a pointer containing the response from a prior call to `vdkWeb_Request` or `vdkWeb_RequestAdv`.
  //! @result  A vdkError value based on the result of releasing the HTTP response.
  //!
  VDKDLL_API enum vdkError vdkWeb_ReleaseResponse(const char **ppResponse);

#ifdef __cplusplus
}
#endif

#endif // vdkWeb_h__
