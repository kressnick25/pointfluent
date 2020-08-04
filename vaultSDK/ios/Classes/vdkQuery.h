#ifndef vdkQuery_h__
#define vdkQuery_h__

//! @file vdkQuery.h
//! The vdkQuery object provides an interface to query or filter pointclouds.

#include <stdint.h>
#include <stdbool.h>

#include "vdkDLLExport.h"
#include "vdkError.h"
#include "vdkPointCloud.h"
#include "vdkPointBuffer.h"

#ifdef __cplusplus
extern "C" {
#endif

  struct vdkQuery;
  struct vdkQueryFilter;

  struct vdkRenderInstance; // From vdkRenderContext.h

  //!
  //! Create an instance of a vdkQueryFilter.
  //!
  //! @param ppQueryFilter The pointer pointer of the vdkQueryFilter. This will allocate an instance of vdkQueryFilter into `ppQueryFilter`.
  //! @return A vdkError value based on the result of the vdkQueryFilter creation.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_Create(struct vdkQueryFilter **ppQueryFilter);

  //!
  //! Destroy the instance of vdkQueryFilter.
  //!
  //! @param ppQueryFilter The pointer pointer of the vdkQueryFilter. This will deallocate the instance of vdkQueryFilter.
  //! @return A vdkError value based on the result of the vdkQueryFilter destruction.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_Destroy(struct vdkQueryFilter **ppQueryFilter);

  //!
  //! Invert the result of a vdkQueryFilter.
  //!
  //! @param pQueryFilter The vdkQueryFilter to configure.
  //! @param inverted True if the filter should be inverted, False is it should behave as default.
  //! @return A vdkError value based on the result of the operation.
  //! @note Different filters may behave differently when inverted, see notes on each type.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_SetInverted(struct vdkQueryFilter *pQueryFilter, bool inverted);

  //!
  //! Set the vdkQueryFilter to find voxels within a box.
  //!
  //! @param pQueryFilter The vdkQueryFilter to configure.
  //! @param centrePoint The world space {X,Y,Z} array for the center point.
  //! @param halfSize The local space {X,Y,Z} half size of the box (the world space axis are defined by yawPitchRoll).
  //! @param yawPitchRoll The rotation of the model (in radians). Applied in YPR order.
  //! @return A vdkError value based on the result of the operation.
  //! @note When inverted, this filter will return all points outside the box.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_SetAsBox(struct vdkQueryFilter *pQueryFilter, const double centrePoint[3], const double halfSize[3], const double yawPitchRoll[3]);

  //!
  //! Set the vdkQueryFilter to find voxels within a cylinder.
  //!
  //! @param pQueryFilter The vdkQueryFilter to configure.
  //! @param centrePoint The world space {X,Y,Z} array for the center point of the cylinder.
  //! @param radius The radius of the cylinder (the world space axis are defined by yawPitchRoll) the circle exists in local axis XY extruded along Z.
  //! @param halfHeight The half-height of the cylinder (the world space axis are defined by yawPitchRoll) the circle exists in local axis XY extruded along Z.
  //! @param yawPitchRoll The rotation of the cylinder (in radians). Applied in YPR order.
  //! @return A vdkError value based on the result of the operation.
  //! @note When inverted, this filter will return all points outside the cylinder.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_SetAsCylinder(struct vdkQueryFilter *pQueryFilter, const double centrePoint[3], const double radius, const double halfHeight, const double yawPitchRoll[3]);

  //!
  //! Set the vdkQueryFilter to find voxels within a sphere.
  //!
  //! @param pQueryFilter The vdkQueryFilter to configure.
  //! @param centrePoint The world space {X,Y,Z} array for the center point.
  //! @param radius The radius from the centerPoint to the edge of the sphere.
  //! @return A vdkError value based on the result of the operation.
  //! @note When inverted, this filter will return all points outside the sphere.
  //!
  VDKDLL_API enum vdkError vdkQueryFilter_SetAsSphere(struct vdkQueryFilter *pQueryFilter, const double centrePoint[3], const double radius);

  //!
  //! Create an instance of a vdkQuery with a specific model.
  //!
  //! @param pContext The context to be used to create the query context.
  //! @param ppQuery The pointer pointer of the vdkQuery. This will allocate an instance of vdkQuery into `ppQuery`.
  //! @param pPointCloud The point cloud to run the query on, it is located at its storedMatrix location.
  //! @param pFilter The filter to use in this query (this can be changed using vdkQuery_ApplyNewFilter.
  //! @return A vdkError value based on the result of the vdkQuery creation.
  //! @note A future release will add multiple model support and non-storedMatrix locations.
  //!
  VDKDLL_API enum vdkError vdkQuery_Create(struct vdkContext *pContext, struct vdkQuery **ppQuery, struct vdkPointCloud *pPointCloud, const struct vdkQueryFilter *pFilter);

  //!
  //! Resets the vdkQuery and uses a new filter.
  //!
  //! @param pQuery The vdkQuery item previously created using vdkQuery_Create.
  //! @param pFilter The new filter to use in this query.
  //! @return A vdkError value based on the result of the operation.
  //! @note This will reset the query, any existing progress will be lost.
  //!
  VDKDLL_API enum vdkError vdkQuery_ChangeFilter(struct vdkQuery *pQuery, const struct vdkQueryFilter *pFilter);

  //!
  //! Resets the vdkQuery and uses a different model.
  //!
  //! @param pQuery The vdkQuery item previously created using vdkQuery_Create.
  //! @param pPointCloud The new model to use in this query.
  //! @return A vdkError value based on the result of the operation.
  //! @note This will reset the query, any existing progress will be lost.
  //!
  VDKDLL_API enum vdkError vdkQuery_ChangeModel(struct vdkQuery *pQuery, const struct vdkPointCloud *pPointCloud);

  //!
  //! Gets the next set of points from an existing vdkQuery.
  //!
  //! @param pQuery The vdkQuery to execute.
  //! @param pPoints The point buffer to write found points to.
  //! @return A vdkError value based on the result of the operation. 
  //! @note This should continue to be called until it returns vE_NotFound indicating the query has completed.
  //!
  VDKDLL_API enum vdkError vdkQuery_ExecuteF64(struct vdkQuery *pQuery, struct vdkPointBufferF64 *pPoints);

  //!
  //! Gets the next set of points from an existing vdkQuery.
  //!
  //! @param pQuery The vdkQuery to execute.
  //! @param pPoints The point buffer to write found points to.
  //! @return A vdkError value based on the result of the operation.
  //! @note This should continue to be called until it returns vE_NotFound indicating the query has completed.
  //!
  VDKDLL_API enum vdkError vdkQuery_ExecuteI64(struct vdkQuery *pQuery, struct vdkPointBufferI64 *pPoints);

  //!
  //! Destroy the instance of vdkQuery.
  //!
  //! @param ppQuery The pointer pointer of the vdkQuery. This will destroy the instance of vdkQuery in `ppQuery` and set it to NULL.
  //! @return A vdkError value based on the result of the vdkQueryFilter destruction.
  //!
  VDKDLL_API enum vdkError vdkQuery_Destroy(struct vdkQuery **ppQuery);

#ifdef __cplusplus
}
#endif

#endif // vdkQuery_h__
