#ifndef vdkRenderContext_h__
#define vdkRenderContext_h__

//! @file vdkRenderContext.h
//! The **vdkRenderContext** object provides an interface to render Euclideon Unlimited Detail models.
//! It provides the ability to render by colour, intensity or classification; additionally allowing the user to query a specific pixel for information about the pointcloud data.

#include "vdkDLLExport.h"
#include "vdkError.h"
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

struct vdkContext;
struct vdkRenderView;
struct vdkPointCloud;

//!
//! @struct vdkRenderContext
//! Stores the internal state of the VDK render system
//!
struct vdkRenderContext;

//!
//! These are the various point modes available in VDK
//!
enum vdkRenderContextPointMode
{
  vdkRCPM_Rectangles, //!< This is the default, renders the voxels expanded as screen space rectangles
  vdkRCPM_Cubes, //!< Renders the voxels as cubes
  vdkRCPM_Points, //!< Renders voxels as a single point (Note: does not accurately reflect the 'size' of voxels)

  vdkRCPM_Count //!< Total number of point modes. Used internally but can be used as an iterator max when displaying different point modes.
};

//!
//! These are the various render flags available in VDK
//!
enum vdkRenderFlags
{
  vdkRF_None = 0, //!< Render the points using the default configuration.

  vdkRF_PreserveBuffers = 1 << 0, //!< The colour and depth buffers won't be cleared before drawing and existing depth will be respected
  vdkRF_ComplexIntersections = 1 << 1, //!< This flag is required in some scenes where there is a very large amount of intersecting point clouds
                                       //!< It will internally batch rendering with the vdkRF_PreserveBuffers flag after the first render.
  vdkRF_BlockingStreaming = 1 << 2, //!< This forces the streamer to load as much of the pointcloud as required to give an accurate representation in the current view. A small amount of further refinement may still occur.

  vdkRF_LogarithmicDepth = 1 << 3 //!< Calculate the depth as a logarithmic distribution.
};

//!
//! These are the various render flags available in VDK
//!
enum vdkRenderModelFlags
{
  vdkRMF_None = 0, //!< Render the points using the default configuration.
};

//!
//! @struct vdkRenderPicking
//! Stores both the input and output of the VDK picking system
//!
struct vdkRenderPicking
{
  // Input variables
  unsigned int x; //!< vdkRenderView space Mouse X
  unsigned int y; //!< vdkRenderView space Mouse Y

  // Output variables
  bool hit; //!< True if a voxel was hit by this pick
  bool isHighestLOD; //!< True if this voxel that was hit is as precise as possible
  unsigned int modelIndex; //!< Index of the model in the ppModels list
  double pointCenter[3]; //!< The center of the hit voxel in world space
  uint64_t voxelID; //!< The ID of the voxel that was hit by the pick; this ID is only valid for a very short period of time- Do any additional work using this ID this frame.
};

//!
//! @struct vdkRenderOptions
//! Stores the render options of the VDK
//!
struct vdkRenderOptions
{
  enum vdkRenderFlags flags; //!< Optional flags providing information about how to perform this render
  struct vdkRenderPicking *pPick; //!< Optional This provides information about the voxel under the mouse
  enum vdkRenderContextPointMode pointMode; //!< The point mode for this render
  struct vdkQueryFilter *pFilter; //!< Optional This filter is applied to all models in the scene
};

//!
//! @struct vdkRenderInstance
//! Stores the instance settings of a model to be rendered
//!
struct vdkRenderInstance
{
  struct vdkPointCloud *pPointCloud; //!< This is the point cloud to display
  double matrix[16]; //!< The world space matrix for this point cloud instance (this does not to be the default matrix)
                     //!< @note The default matrix for a model can be accessed from the associated vdkPointCloudHeader

  enum vdkRenderModelFlags modelFlags; //!< The settings to apply to this model
  const struct vdkQueryFilter *pFilter; //!< Filter to override for this model, this one will be used instead of the global one applied in vdkRenderOptions

  uint32_t (*pVoxelShader)(struct vdkPointCloud *pPointCloud, uint64_t voxelID, const void *pVoxelUserData); //!< When the renderer goes to select a colour, it calls this function instead
  void *pVoxelUserData; //!< If pVoxelShader is set, this parameter is passed to that function
};

//!
//! Create an instance of `vdkRenderContext` for rendering.
//!
//! @param pContext The context to be used to create the render context.
//! @param ppRenderer The pointer pointer of the vdkRenderContext. This will allocate an instance of vdkRenderContext into `ppRenderer`.
//! @return A vdkError value based on the result of the render context creation.
//! @note It is not recommended to have more than one instance of vdkRenderContext.
//!
VDKDLL_API enum vdkError vdkRenderContext_Create(struct vdkContext *pContext, struct vdkRenderContext **ppRenderer);

//!
//! Destroy the instance of the renderer.
//!
//! @param ppRenderer The pointer pointer of the vdkRenderContext. This will deallocate the instance of vdkRenderContext.
//! @return A vdkError value based on the result of the render context destruction.
//!
VDKDLL_API enum vdkError vdkRenderContext_Destroy(struct vdkRenderContext **ppRenderer);

//!
//! Render the models from the perspective of `pRenderView`.
//!
//! @param pRenderer The renderer to render the scene.
//! @param pRenderView The view to render from with the render buffers associated with it being filled out.
//! @param pModels The array of models to use in render.
//! @param modelCount The amount of models in pModels.
//! @param pRenderOptions Additional render options.
//! @return A vdkError value based on the result of the render.
//!
VDKDLL_API enum vdkError vdkRenderContext_Render(struct vdkRenderContext *pRenderer, struct vdkRenderView *pRenderView, struct vdkRenderInstance *pModels, int modelCount, struct vdkRenderOptions *pRenderOptions);

#ifdef __cplusplus
}
#endif

#endif // vdkRenderContext_h__
