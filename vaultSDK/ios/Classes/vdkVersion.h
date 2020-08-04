#ifndef vdkVersion_h__
#define vdkVersion_h__

//! @file vdkVersion.h
//! The **vdkVersion** object provides an interface to query the version of the loaded VDK library.

#include <stdint.h>
#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

//! The major version part of the library version
# define VDK_MAJOR_VERSION 0
//! The minor version part of the library version
# define VDK_MINOR_VERSION 5
//! The patch version part of the library version
# define VDK_PATCH_VERSION 1

  //!
  //! Stores the version information for the loaded VDK library.
  //!
  struct vdkVersion
  {
    uint8_t major; //!< The major version part of the library version
    uint8_t minor; //!< The minor version part of the library version
    uint8_t patch; //!< The patch version part of the library version
  };

  //!
  //! Populates the provided structure with the version information for the loaded VDK library.
  //!
  //! @param pVersion The version structure which will be populated with the version information.
  //! @return A vdkError value based on the result of getting the version information.
  //!
  VDKDLL_API enum vdkError vdkVersion_GetVersion(struct vdkVersion *pVersion);

#ifdef __cplusplus
}
#endif

#endif // vdkVersion_h__
