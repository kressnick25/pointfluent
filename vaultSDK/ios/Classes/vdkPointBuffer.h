#ifndef vdkPointBuffer_h__
#define vdkPointBuffer_h__

//! @file vdkPointBuffer.h
//! The vdkPointBuffer object provides an interface to add or get points from vdkPointClouds

#include "vdkDLLExport.h"
#include "vdkAttributes.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

  //!
  //! @struct vdkPointBufferF64
  //! Stores a set of points and their attributes that have positions as double (64bit float) values
  //!
struct vdkPointBufferF64
{
  double *pPositions; //!< Flat array of XYZ positions in the format XYZXYZXYZXYZXYZXYZXYZ...
  uint8_t *pAttributes; //!< Byte array of attribute data ordered as specified in `attributes`
  struct vdkAttributeSet attributes; //!< Information on the attributes that are available in this point buffer
  uint32_t positionStride; //!< Total bytes between the start of one position and the start of the next (currently always 24 (8 bytes per double * 3 doubles))
  uint32_t attributeStride; //!< Total number of bytes between the start of the attibutes of one point and the first byte of the next attribute
  uint32_t pointCount; //!< How many points are currently contained in this buffer
  uint32_t pointsAllocated; //!< Total number of points that can fit in this vdkPointBufferF64
  uint32_t _reserved; //!< Reserved for internal use
};

//!
//! @struct vdkPointBufferI64
//! Stores a set of points and their attributes that have positions as Int64 values
//!
struct vdkPointBufferI64
{
  int64_t *pPositions;  //!< Flat array of XYZ positions in the format XYZXYZXYZXYZXYZXYZXYZ...
  uint8_t *pAttributes; //!< Byte array of attribute data ordered as specified in `attributes`
  struct vdkAttributeSet attributes; //!< Information on the attributes that are available in this point buffer
  uint32_t positionStride; //!< Total bytes between the start of one position and the start of the next (currently always 24 (8 bytes per int64 * 3 int64))
  uint32_t attributeStride; //!< Total number of bytes between the start of the attibutes of one point and the first byte of the next attribute
  uint32_t pointCount; //!< How many points are currently contained in this buffer
  uint32_t pointsAllocated; //!< Total number of points that can fit in this vdkPointBufferF64
  uint32_t _reserved; //!< Reserved for internal use
};

//!
//! Create a 64bit floating point, point buffer object
//!
//! @param ppBuffer The pointer pointer of the vdkPointBufferF64. This will allocate an instance of `vdkPointBufferF64` into `ppBuffer`.
//! @param maxPoints The maximum number of points that this buffer will contain (these are preallocated to avoid allocations later)
//! @param pAttributes The pointer to the vdkAttributeSet containing information on the attributes that will be available in this point buffer; NULL will have no attributes. An internal copy is made of this attribute set.
//! @return A vdkError value based on creation status.
//! @note The application should call **vdkPointBufferF64_Destroy** with `ppBuffer` to destroy the point buffer object once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkPointBufferF64_Create(struct vdkPointBufferF64 **ppBuffer, uint32_t maxPoints, struct vdkAttributeSet *pAttributes);

//!
//! Destroys the vdkPointBufferF64.
//!
//! @param ppBuffer The pointer pointer of the ppBuffer. This will deallocate any memory used.
//! @return A vdkError value based on the result of the destruction.
//! @note The value of `ppBuffer` will be set to `NULL`.
//!
VDKDLL_API enum vdkError vdkPointBufferF64_Destroy(struct vdkPointBufferF64 **ppBuffer);

//!
//! Create a 64bit integer, point buffer object
//!
//! @param ppBuffer The pointer pointer of the vdkPointBufferI64. This will allocate an instance of `vdkPointBufferI64` into `ppBuffer`.
//! @param maxPoints The maximum number of points that this buffer will contain (these are preallocated to avoid allocations later)
//! @param pAttributes The pointer to the vdkAttributeSet containing information on the attributes that will be available in this point buffer; NULL will have no attributes. An internal copy is made of this attribute set.
//! @return A vdkError value based on creation status.
//! @note The application should call **vdkPointBufferI64_Destroy** with `ppBuffer` to destroy the point buffer object once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkPointBufferI64_Create(struct vdkPointBufferI64 **ppBuffer, uint32_t maxPoints, struct vdkAttributeSet *pAttributes);

//!
//! Destroys the vdkPointBufferI64.
//!
//! @param ppBuffer The pointer pointer of the ppBuffer. This will deallocate any memory used.
//! @return A vdkError value based on the result of the destruction.
//! @note The value of `ppBuffer` will be set to `NULL`.
//!
VDKDLL_API enum vdkError vdkPointBufferI64_Destroy(struct vdkPointBufferI64 **ppBuffer);

#ifdef __cplusplus
}
#endif

#endif // vdkVersion_h__
