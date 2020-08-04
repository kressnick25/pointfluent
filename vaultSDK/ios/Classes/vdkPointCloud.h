#ifndef vdkPointCloud_h__
#define vdkPointCloud_h__

//! @file vdkPointCloud.h
//! The **vdkPointCloud** object provides an interface to load a Euclideon Unlimited Detail model.
//! Once instantiated, the **vdkPointCloud** can be queried for metadata information, and rendered with the vdkRenderContext functions.
//! Future releases will allow users to also query the pointcloud data itself, providing the ability to export to LAS or render sub-sections of the pointcloud.

#include "vdkDLLExport.h"
#include "vdkAttributes.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

struct vdkContext;
struct vdkQueryFilter;

//!
//! @struct vdkPointCloudHeader
//! Stores basic information about a vdkPointCloud
//!
struct vdkPointCloudHeader
{
  double scaledRange; //!< The point cloud's range multiplied by the voxel size
  double unitMeterScale; //!< The scale to apply to convert to/from metres (after scaledRange is applied to the unitCube)
  uint32_t totalLODLayers; //!< The total number of LOD layers in this octree
  double convertedResolution; //!< The resolution this model was converted at
  double storedMatrix[16]; //!< This matrix is the 'default' internal matrix to go from a unit cube to the full size

  struct vdkAttributeSet attributes;   //!< The attributes contained in this pointcloud

  double baseOffset[3]; //!< The offset to the root of the pointcloud in unit cube space
  double pivot[3]; //!< The pivot point of the model, in unit cube space
  double boundingBoxCenter[3]; //!< The center of the bounding volume, in unit cube space
  double boundingBoxExtents[3]; //!< The extents of the bounding volume, in unit cube space
};

//!
//! @struct vdkPointCloud
//! Stores the internal state of a VDK pointcloud
//!
struct vdkPointCloud;

//!
//! Load a vdkPointCloud from `modelLocation`.
//!
//! @param pContext The context to be used to load the model.
//! @param ppModel The pointer pointer of the vdkPointCloud. This will allocate an instance of `vdkPointCloud` into `ppModel`.
//! @param modelLocation The location to load the model from. This may be a file location, or a supported protocol (HTTP, HTTPS, FTP).
//! @param pHeader If non-null, the provided vdkPointCloudHeader structure will be writen to
//! @return A vdkError value based on the result of the model load.
//! @note The application should call **vdkPointCloud_Unload** with `ppModel` to destroy the object once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkPointCloud_Load(struct vdkContext *pContext, struct vdkPointCloud **ppModel, const char *modelLocation, struct vdkPointCloudHeader *pHeader);

//!
//! Destroys the vdkPointCloud.
//!
//! @param ppModel The pointer pointer of the vdkPointCloud. This will deallocate any internal memory used. It may take a few frames before the streamer releases the internal memory.
//! @return A vdkError value based on the result of the model unload.
//! @note The value of `ppModel` will be set to `NULL`.
//!
VDKDLL_API enum vdkError vdkPointCloud_Unload(struct vdkPointCloud **ppModel);

//!
//! Get the metadata associated with this object.
//!
//! @param pPointCloud The point cloud model to get the metadata from.
//! @param ppJSONMetadata The metadata(in JSON) from the model.
//! @return A vdkError value based on the result of getting the model metadata.
//!
VDKDLL_API enum vdkError vdkPointCloud_GetMetadata(struct vdkPointCloud *pPointCloud, const char **ppJSONMetadata);

//!
//! Get the matrix of this model.
//!
//! @param pPointCloud The point cloud model to get the matrix from.
//! @param pHeader The header structure to fill out
//! @return A vdkError value based on the result of getting the model header.
//! @note All Unlimited Detail models are assumed to be from { 0, 0, 0 } to { 1, 1, 1 }. Any scaling applied to the model will be in this matrix along with the translation and rotation.
//!
VDKDLL_API enum vdkError vdkPointCloud_GetHeader(struct vdkPointCloud *pPointCloud, struct vdkPointCloudHeader *pHeader);

//!
//! Exports a point cloud
//!
//! @param pModel The loaded pointcloud to export.
//! @param pExportFilename The path and filename to export the point cloud to. This should be a file location with write permissions. Supported formats are .UDS and .LAS.
//! @param pFilter If non-NULL this filter will be applied on the export to export a subsection
//! @return A vdkError value based on the result of the model export
//! @warning If an existing file exists this function will try override it
//!
VDKDLL_API enum vdkError vdkPointCloud_Export(struct vdkPointCloud *pModel, const char *pExportFilename, const struct vdkQueryFilter *pFilter);

//!
//! Gets the default colour for a specific voxel in a given point cloud
//!
//! @param pModel The point cloud to get a default colour for.
//! @param voxelID The voxelID provided by picking or to voxel shaders
//! @param pColour The address to write the colour of the given voxel to
//! @return A vdkError value based on the result of getting the colour
//! @warning Calling this with invalid inputs can easily crash the program
//!
VDKDLL_API enum vdkError vdkPointCloud_GetNodeColour(const struct vdkPointCloud *pModel, uint64_t voxelID, uint32_t *pColour);

//!
//! Gets the pointer to the attribute offset on a specific voxel in a point cloud
//!
//! @param pModel The point cloud to get an address for.
//! @param voxelID The voxelID provided by picking or to voxel shaders
//! @param attributeOffset The attribute offset from vdkAttributeSet_GetOffsetOfNamedAttribute or vdkAttributeSet_GetOffsetOfStandardAttribute
//! @param ppAttributeAddress The pointer will be updated with the address to the attribute
//! @return A vdkError value based on the result of getting the attribute address
//! @warning Calling this with invalid inputs can easily crash the program
//!
VDKDLL_API enum vdkError vdkPointCloud_GetAttributeAddress(struct vdkPointCloud *pModel, uint64_t voxelID, uint32_t attributeOffset, const void **ppAttributeAddress);

#ifdef __cplusplus
}
#endif

#endif // vdkPointCloud_h__
