#ifndef vdkServerAPI_h__
#define vdkServerAPI_h__

//! @file vdkServerAPI.h
//! The **vdkServerAPI** module provides an interface to communicate with a Euclideon Vault server API directly in a simple fashion.

#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

struct vdkContext;

//!
//! Queries provided API on the specified Euclideon Vault Server.
//!
//! @param pContext The context to execute the query with.
//! @param pAPIAddress The API address to query, this is the part of the address *after* `/api/`. The rest of the address is constructed from the context provided.
//! @param pJSON The JSON text to POST to the API address.
//! @param ppResult A pointer to a location in which the result data is to be stored.
//! @result A vdkError value based on the result of the API query.
//! @note The application should call **vdkServerAPI_ReleaseResult** with `ppResult` to destroy the data once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkServerAPI_Query(struct vdkContext *pContext, const char *pAPIAddress, const char *pJSON, const char **ppResult);

//!
//! Destroys the result that was allocated.
//!
//! @param ppResult A pointer to a location in which the result data is stored.
//! @note The value of `ppResult` will be set to `NULL`.
//!
VDKDLL_API enum vdkError vdkServerAPI_ReleaseResult(const char **ppResult);

#ifdef __cplusplus
}
#endif

#endif // vdkServerAPI_h__
