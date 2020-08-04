#ifndef vdkRenderView_h__
#define vdkRenderView_h__

//! @file vdkRenderView.h
//! The **vdkRenderView** object provides an interface to specify a viewport to render to.
//! Once instantiated, the **vdkRenderView** can have its targets set, providing both a colour and depth output of the render which will utilize the matrices provided to the SetMatrix function.

#include <stdint.h>
#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

struct vdkContext;
struct vdkRenderContext;

//!
//! @struct vdkRenderView
//! Stores the internal state of a VDK render view
//!
struct vdkRenderView;

//!
//! These are the various matrix types used within the render view
//!
enum vdkRenderViewMatrix
{
  vdkRVM_Camera,     //!< The local to world-space transform of the camera (View is implicitly set as the inverse)
  vdkRVM_View,       //!< The view-space transform for the model (does not need to be set explicitly)
  vdkRVM_Projection, //!< The projection matrix (default is 60 degree LH)
  vdkRVM_Viewport,   //!< Viewport scaling matrix (default width and height of viewport)

  vdkRVM_Count       //!< Total number of matrix types. Used internally but can be used as an iterator max when checking matrix information.
};

//!
//! Create a RenderView with a viewport using `width` and `height`.
//!
//! @param pContext The context to be used to create the render view.
//! @param ppRenderView The pointer pointer of the vdkRenderView.This will allocate an instance of vdkRenderView into `ppRenderView`.
//! @param pRenderer The renderer associated with the render view.
//! @param width The width of the viewport.
//! @param height The height of the viewport.
//! @return A vdkError value based on the result of the view creation.
//! @note The application should call **vdkRenderView_Destroy** with `ppRenderView` to destroy the object once it's no longer needed.
//!
VDKDLL_API enum vdkError vdkRenderView_Create(struct vdkContext *pContext, struct vdkRenderView **ppRenderView, struct vdkRenderContext *pRenderer, uint32_t width, uint32_t height);

//!
//! Destroys the instance of `ppRenderView`.
//!
//! @param ppRenderView The pointer pointer of the vdkRenderView. This will deallocate the instance of vdkRenderView.
//! @return A vdkError value based on the result of the view destruction.
//! @note The value of `ppRenderView` will be set to `NULL`.
//!
VDKDLL_API enum vdkError vdkRenderView_Destroy(struct vdkRenderView **ppRenderView);

//!
//! Set a target buffer to a view.
//!
//! @param pRenderView The render view to associate a target buffer with.
//! @param pColorBuffer The color buffer, if null the buffer will not be rendered to anymore.
//! @param colorClearValue The clear value to clear the color buffer with.
//! @param pDepthBuffer The depth buffer, if null the buffer will not be rendered to anymore.
//! @return A vdkError value based on the result of setting the targets.
//! @note This internally calls vdkRenderView_SetTargetsWithPitch with both color and depth pitches set to 0.
//!
VDKDLL_API enum vdkError vdkRenderView_SetTargets(struct vdkRenderView *pRenderView, void *pColorBuffer, uint32_t colorClearValue, void *pDepthBuffer);

//!
//! Set a target buffer to a view.
//!
//! @param pRenderView The render view to associate a target buffer with.
//! @param pColorBuffer The color buffer, if null the buffer will not be rendered to anymore.
//! @param colorClearValue The clear value to clear the color buffer with.
//! @param pDepthBuffer The depth buffer, if null the buffer will not be rendered to anymore.
//! @param colorPitchInBytes The number of bytes that make up a row of the color buffer.
//! @param depthPitchInBytes The number of bytes that make up a row of the depth buffer.
//! @return A vdkError value based on the result of setting the targets.
//!
VDKDLL_API enum vdkError vdkRenderView_SetTargetsWithPitch(struct vdkRenderView *pRenderView, void *pColorBuffer, uint32_t colorClearValue, void *pDepthBuffer, uint32_t colorPitchInBytes, uint32_t depthPitchInBytes);

//!
//! Get the matrix associated with `pRenderView` of type `matrixType` and fill it in `cameraMatrix`.
//!
//! @param pRenderView The render view to get the matrix from.
//! @param matrixType The type of matrix to get.
//! @param cameraMatrix The array of 16 doubles which gets filled out with the matrix.
//! @return A vdkError value based on the result of getting the matrix.
//!
VDKDLL_API enum vdkError vdkRenderView_GetMatrix(const struct vdkRenderView *pRenderView, enum vdkRenderViewMatrix matrixType, double cameraMatrix[16]);

//!
//! Set the matrix associated with `pRenderView` of type `matrixType` and get it from `cameraMatrix`.
//!
//! @param pRenderView The render view to set the matrix to.
//! @param matrixType The type of matrix to set.
//! @param cameraMatrix The array of 16 doubles to fill out the internal matrix with.
//! @return A vdkError value based on the result of setting the matrix.
//!
VDKDLL_API enum vdkError vdkRenderView_SetMatrix(struct vdkRenderView *pRenderView, enum vdkRenderViewMatrix matrixType, const double cameraMatrix[16]);

#ifdef __cplusplus
}
#endif

#endif // vdkRenderView_h__
