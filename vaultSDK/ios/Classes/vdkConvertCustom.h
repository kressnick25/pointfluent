#ifndef vdkConvertCustom_h__
#define vdkConvertCustom_h__

//! @file vdkConvertCustom.h
//! vdkConvertCustomItem provides a way to convert proprietary or unsupported file formats to Unlimited Detail format

#include "vdkConvert.h"
#include "vdkAttributes.h"
#include "vdkPointCloud.h"
#include "vdkPointBuffer.h"

#ifdef __cplusplus
extern "C" {
#endif

  //!
  //! Settings the custom converts need to be aware of that are set by the user
  //!
  enum vdkConvertCustomItemFlags
  {
    vdkCCIF_None = 0, //!< No additional flags specified
    vdkCCIF_SkipErrorsWherePossible = 1, //!< If its possible to continue parsing, that is perferable to failing
    vdkCCIF_PolygonVerticesOnly = 2, //!< Do not rasterise the polygons, just use the vertices as points
  };

  //!
  //! @struct vdkConvertCustomItem
  //! Allows for conversion of custom data formats to UDS
  //!
  struct vdkConvertCustomItem
  {
    enum vdkError(*pOpen)(struct vdkConvertCustomItem *pConvertInput, uint32_t everyNth, const double origin[3], double pointResolution, enum vdkConvertCustomItemFlags flags); //!< Open the file and provide information on the file (bounds, point count, etc.)
    enum vdkError(*pReadPointsInt)(struct vdkConvertCustomItem *pConvertInput, struct vdkPointBufferI64 *pBuffer); //!< If the position data will be provided as integer values, provide a function pointer here
    enum vdkError(*pReadPointsFloat)(struct vdkConvertCustomItem *pConvertInput, struct vdkPointBufferF64 *pBuffer); //!< If the position data will be provided as double floating point values, provide a function pointer here
    void(*pDestroy)(struct vdkConvertCustomItem *pConvertInput); //!< Cleanup all memory related to this custom convert item
    void(*pClose)(struct vdkConvertCustomItem *pConvertInput); //!< This function will be called when 

    void *pData; //!< Private user data relevant to the specific geomtype, must be freed by the pClose function

    const char *pName; //!< Filename or other identifier
    double boundMin[3]; //!< Optional (see boundsKnown) source space minimum values
    double boundMax[3]; //!< Optional (see boundsKnown) source space maximum values
    double sourceResolution; //!< Source resolution (eg 0.01 if points are 1cm apart). 0 indicates unknown
    int64_t pointCount; //!< Number of points coming, -1 if unknown
    int32_t srid; //!< If non-zero, this input is considered to be within the given srid code (useful mainly as a default value for other files in the conversion)
    struct vdkAttributeSet attributes; //!< Content of the input; this might not match the output
    enum vdkConvertSourceProjection sourceProjection; //!< SourceLatLong defines x as latitude, y as longitude in WGS84.
    bool boundsKnown; //!< If true, boundMin and boundMax are valid, if false they will be calculated later
    bool pointCountIsEstimate; //!< If true, the point count is an estimate and may be different
  };

  //!
  //! Adds a prefilled vdkConvertCustomItem to a vdkConvertContext
  //!
  //! @param pConvertContext The convert context to add the item to
  //! @param pCustomItem The custom convert item to add
  //! @return A vdkError value based on the result of adding the item
  //!
  VDKDLL_API enum vdkError vdkConvert_AddCustomItem(struct vdkConvertContext *pConvertContext, struct vdkConvertCustomItem *pCustomItem);

#ifdef __cplusplus
}
#endif

#endif // vdkConvertCustom_h__
