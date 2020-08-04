#ifndef vdkConvert_h__
#define vdkConvert_h__

//! @file vdkConvert.h
//! The **vdkConvert** object provides an interface to create a Euclideon Unlimited Detail model from a number of supported pointcloud formats.
//! Once instantiated, the **vdkConvert** object can be populated with input files and various conversion settings, before initiating the conversion process.

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>
#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

  struct vdkContext;
  struct vdkPointCloud;

  //!
  //! @struct vdkConvertContext
  //! Stores the internal state of the convert system
  //!
  struct vdkConvertContext;

  //!
  //! These are the various source projections
  //!
  enum vdkConvertSourceProjection
  {
    vdkCSP_SourceCartesian, //!< The source is in cartesian already
    vdkCSP_SourceLatLong, //!< The source is in LatLong and will need to be converted to Cartesian using the SRID
    vdkCSP_SourceLongLat, //!< The source is in LongLat and will need to be converted to Cartesian using the SRID
    vdkCSP_SourceEarthCenteredAndFixed, //!< The source points are stored relative to the center of the earth

    vdkCSP_Count //!< Total number of source projections. Used internally but can be used as an iterator max when displaying different projections.
  };

  //!
  //! @struct vdkConvertInfo
  //! Provides a copy of a subset of the convert state
  //!
  struct vdkConvertInfo
  {
    const char *pOutputName; //!< The output filename
    const char *pTempFilesPrefix; //!< The file prefix for temp files

    const char *pMetadata; //!< The metadata that will be added to this model (in JSON format)
    const char *pWatermark; //!< Base64 Encoded PNG watermark (in the format it gets stored in the metadata)

    double globalOffset[3]; //!< This amount is added to every point during conversion. Useful for moving the origin of the entire scene to geolocate

    double minPointResolution; //!< The native resolution of the highest resolution file
    double maxPointResolution; //!< The native resolution of the lowest resolution file
    bool skipErrorsWherePossible; //!< If true it will continue processing other files if a file is detected as corrupt or incorrect

    uint32_t everyNth; //!< If this value is >1, only every Nth point is included in the model. e.g. 4 means only every 4th point will be included, skipping 3/4 of the points
    bool polygonVerticesOnly; //!< If true it will skip rasterization of polygons in favour of just processing the vertices

    bool overrideResolution; //!< Set to true to stop the resolution from being recalculated
    double pointResolution; //!< The scale to be used in the conversion (either calculated or overriden)

    bool overrideSRID; //!< Set to true to prevent the SRID being recalculated
    int srid; //!< The geospatial reference ID (either calculated or overriden)

    uint64_t totalPointsRead; //!< How many points have been read in this model
    uint64_t totalItems; //!< How many items are in the list

    // These are quick stats while converting
    uint64_t currentInputItem; //!< The index of the item that is currently being read
    uint64_t outputFileSize; //!< Size of the result UDS file
    uint64_t sourcePointCount; //!< Number of points added (may include duplicates or out of range points)
    uint64_t uniquePointCount; //!< Number of unique points in the final model
    uint64_t discardedPointCount; //!< Number of duplicate or ignored out of range points
    uint64_t outputPointCount; //!< Number of points written to UDS (can be used for progress)
    uint64_t peakDiskUsage; //!< Peak amount of disk space used including both temp files and the actual output file
    uint64_t peakTempFileUsage; //!< Peak amount of disk space that contained temp files
    uint32_t peakTempFileCount; //!< Peak number of temporary files written
  };

  //!
  //! @struct vdkConvertItemInfo
  //! Provides a copy of a subset of a convert item state
  //!
  struct vdkConvertItemInfo
  {
    const char *pFilename; //!< Name of the input file
    int64_t pointsCount; //!< This might be an estimate, -1 is no estimate is available
    uint64_t pointsRead; //!< Once conversation begins, this will give an indication of progress

    enum vdkConvertSourceProjection sourceProjection; //!< What sort of projection this input has
  };

  //!
  //! Create a vdkConvertContext to convert models to the Euclideon file format.
  //!
  //! @param pContext The context to be used to create the convert context.
  //! @param ppConvertContext The pointer pointer of the vdkConvertContext. This will allocate an instance of `vdkConvertContext` into `ppConvertContext`.
  //! @return A vdkError value based on the result of the convert context creation.
  //! @note The application should call **vdkConvert_DestroyContext** with `ppConvertContext` to destroy the object once it's no longer needed.
  //!
  VDKDLL_API enum vdkError vdkConvert_CreateContext(struct vdkContext *pContext, struct vdkConvertContext **ppConvertContext);

  //!
  //! Destroys the instance of `ppConvertContext`.
  //!
  //! @param ppConvertContext The pointer pointer of the vdkConvertContext. This will deallocate the instance of `vdkConvertContext`.
  //! @return A vdkError value based on the result of the convert context destruction.
  //! @note The value of `ppConvertContext` will be set to `NULL`.
  //!
  VDKDLL_API enum vdkError vdkConvert_DestroyContext(struct vdkConvertContext **ppConvertContext);

  //!
  //! Sets the filename of the output UDS.
  //!
  //! @param pConvertContext The convert context to use to set the output filename.
  //! @param pFilename The filename to set for the output.
  //! @return A vdkError value based on the result of setting the output filename.
  //! @note If the .UDS extension isn't set, this function will add the extension.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetOutputFilename(struct vdkConvertContext *pConvertContext, const char *pFilename);

  //!
  //! Sets the temporary output directory for the conversion.
  //!
  //! @param pConvertContext The convert context to use to set the temporary directory.
  //! @param pFolder The folder path to set for the temporary directory.
  //! @return A vdkError value based on the result of setting the temporary directory.
  //! @note A trailing slash is not automatically added, this is to allow for a prefix for the temporary files instead of, or as well as, folders.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetTempDirectory(struct vdkConvertContext *pConvertContext, const char *pFolder);

  //!
  //! Sets the point resolution for the conversion.
  //!
  //! @param pConvertContext The convert context to use to set the point resolution.
  //! @param override A boolean value to indicate whether to override the point resolution or use the auto - detected value.
  //! @param pointResolutionMeters The point resolution in meters.
  //! @return A vdkError value based on the result of setting the point resolution.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetPointResolution(struct vdkConvertContext *pConvertContext, bool override, double pointResolutionMeters);

  //!
  //! Sets the SRID for the conversion.
  //!
  //! @param pConvertContext The convert context to use to set the SRID.
  //! @param override A boolean value to indicate whether to override the SRID or use the auto - detected value.
  //! @param srid The SRID value to use.
  //! @return A vdkError value based on the result of setting the SRID.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetSRID(struct vdkConvertContext *pConvertContext, bool override, int srid);

  //!
  //! This function adds the supplied global offset to each point in the model.
  //!
  //! @param pConvertContext The convert context to set the offset within.
  //! @param globalOffset An array of 3 Doubles representing the desired offset in X, Y and then Z.
  //! @return A vdkError value based on the result of setting the global offset.
  //! @note This is most useful for moving the origin of a model (or set of models) to the false easting and northing of an alternative geozone.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetGlobalOffset(struct vdkConvertContext *pConvertContext, const double globalOffset[3]);

  //!
  //! This function sets the convert context up to attempt to skip errors where it can.
  //!
  //! @param pConvertContext The convert context to use to set the skip errors where possible option.
  //! @param ignoreParseErrorsWherePossible A boolean value to indicate whether to skip errors where possible.
  //! @return A vdkError value based on the result of setting the skip errors where possible option.
  //! @note In most situations this will mean that an input that is corrupt, malformed or not completely supported will be parsed as far as possible and if an error occurs it will skip the rest of this input and begin on the next.
  //! @note Some importers may be able to skip to a later section in the file and continue conversion but this is up to the specific implementation of the importer.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetSkipErrorsWherePossible(struct vdkConvertContext *pConvertContext, bool ignoreParseErrorsWherePossible);

  //!
  //! `EveryNth` lets the importers know to only include every *_n_*th point. If this is set to 0 or 1, every point will be included.
  //!
  //! @param pConvertContext The convert context to set the everyNth param on
  //! @param everyNth How many _n_th points to include. Alternatively, how many (n - 1) points to skip for every point included in the export. _See the example below for a bit more context on what this number means_.
  //! @return A vdkError value based on the result of setting the every Nth option.
  //! @note For many file formats this will be significantly faster to process making this valuable as a tool to test if the resolution and geolocation settings are correct before doing a full conversion.
  //! @note The first (0th) point is always included regardless of this value.
  //!       Example:
  //!         Setting this to `50` would:
  //!           1. Include the first point(point 0)
  //!           2. Skip 49 points
  //!           3. Include the 50th point
  //!           4. Skip another 49 points
  //!           5. Include the 100th point
  //!           n. ...and so on skipping 49 points and including the 50th until all points from this input are processed.
  //!           The next input would then reset the count and include the 0th, skipping 49 etc.as before.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetEveryNth(struct vdkConvertContext *pConvertContext, uint32_t everyNth);

  //!
  //! This function sets the convert context up to skip rasterization of the polygons, leaving only the vertices.
  //!
  //! @param pConvertContext The convert context to use to set the polygonVerticesOnly param on.
  //! @param polygonVerticesOnly A boolean value to indicate whether to skip rasterization of the polygons being converted, leaving only the vertices.
  //! @return A vdkError value based on the result of setting the polygon vertices only option.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetPolygonVerticesOnly(struct vdkConvertContext *pConvertContext, bool polygonVerticesOnly);

  //!
  //! This adds a metadata key to the output UDS file. There are no restrictions on the key.
  //!
  //! @param pConvertContext The convert context to use to set the metadata key.
  //! @param pMetadataKey The name of the key.This is parsed as a JSON address.
  //! @param pMetadataValue The contents of the key, settings this as `NULL` will remove the key from the system (if it exists). This value is handled internal as a string (won't be parsed as JSON).
  //! @return A vdkError value based on the result of setting the metadata key and value.
  //! @note There are a number of 'standard' keys that are recommended to support.
  //!       - `Author`: The name of the company that owns or captured the data
  //!       - `Comment`: A miscellaneous information section
  //!       - `Copyright`: The copyright information
  //!       - `License`: The general license information
  //!
  VDKDLL_API enum vdkError vdkConvert_SetMetadata(struct vdkConvertContext *pConvertContext, const char *pMetadataKey, const char *pMetadataValue);

  //!
  //! This adds an item to be converted in the convert context.
  //!
  //! @param pConvertContext The convert context to add the item to.
  //! @param pFilename The file to add to the convert context.
  //! @return A vdkError value based on the result of adding the item.
  //!
  VDKDLL_API enum vdkError vdkConvert_AddItem(struct vdkConvertContext *pConvertContext, const char *pFilename);

  //!
  //! This removes an item to be converted from the convert context.
  //!
  //! @param pConvertContext The convert context to remove the item from.
  //! @param index The index of the item to remove from the convert context.
  //! @return A vdkError value based on the result of removing the item.
  //!
  VDKDLL_API enum vdkError vdkConvert_RemoveItem(struct vdkConvertContext *pConvertContext, uint64_t index);

  //!
  //! This specifies the projection of the source data.
  //!
  //! @param pConvertContext The convert context to set the input source projection on.
  //! @param index The index of the item to set the source project on.
  //! @param actualProjection The projection to use for the specified item.
  //! @return A vdkError value based on the result of setting the source projection.
  //!
  VDKDLL_API enum vdkError vdkConvert_SetInputSourceProjection(struct vdkConvertContext *pConvertContext, uint64_t index, enum vdkConvertSourceProjection actualProjection);

  //!
  //! This adds a watermark to the output UDS file.
  //!
  //! @param pConvertContext The convert context to add the watermark to.
  //! @param pFilename The file to use for the watermark with the convert context.
  //! @return A vdkError value based on the result of adding the watermark.
  //!
  VDKDLL_API enum vdkError vdkConvert_AddWatermark(struct vdkConvertContext *pConvertContext, const char *pFilename);

  //!
  //! This removes the watermark from the output file.
  //!
  //! @param pConvertContext The convert context to remove the watermark from.
  //! @return A vdkError value based on the result of removing the watermark.
  //!
  VDKDLL_API enum vdkError vdkConvert_RemoveWatermark(struct vdkConvertContext *pConvertContext);

  //!
  //! This provides a way to get the information of the convert context.
  //!
  //! @param pConvertContext The convert context to retrieve the information from.
  //! @param ppInfo The pointer pointer of the vdkConvertInfo. This will be managed by the convert context and does not need to be deallocated.
  //! @return A vdkError value based on the result of getting the information of the convert context.
  //!
  VDKDLL_API enum vdkError vdkConvert_GetInfo(struct vdkConvertContext *pConvertContext, const struct vdkConvertInfo **ppInfo);

  //!
  //! This provides a way to get the information of a specific item in the convert context.
  //!
  //! @param pConvertContext The convert context to retrieve the item information from.
  //! @param index The index of the item to retrieve the information for from the convert context.
  //! @param pInfo The pointer of the vdkConvertItemInfo. The will be populated by the convert context from an internal representation.
  //! @return A vdkError value based on the result of getting the information of the specified item.
  //!
  VDKDLL_API enum vdkError vdkConvert_GetItemInfo(struct vdkConvertContext *pConvertContext, uint64_t index, struct vdkConvertItemInfo *pInfo);

  //!
  //! This begins the conversion process for the provided convert context.
  //!
  //! @param pConvertContext The convert context on which to start the conversion.
  //! @return A vdkError value based on the result of starting the conversion.
  //!
  VDKDLL_API enum vdkError vdkConvert_DoConvert(struct vdkConvertContext *pConvertContext);

  //!
  //! This cancels the running conversion for the provided convert context.
  //!
  //! @param pConvertContext The convert context on which to cancel the conversion.
  //! @return A vdkError value based on the result of cancelling the conversion.
  //!
  VDKDLL_API enum vdkError vdkConvert_Cancel(struct vdkConvertContext *pConvertContext);

  //!
  //! This resets the statis for the provided convert context, for example to re-run a previously completed conversion.
  //!
  //! @param pConvertContext The convert context on which to reset the status.
  //! @return A vdkError value based on the result of resetting the status.
  //!
  VDKDLL_API enum vdkError vdkConvert_Reset(struct vdkConvertContext *pConvertContext);

  //!
  //! This generates a preview of the provided convert context.
  //!
  //! @param pConvertContext The convert context to generate the preview for.
  //! @param ppCloud The pointer pointer of the vdkPointCloud. This will allocate an instance of `vdkPointCloud` into `ppCloud`.
  //! @return A vdkError value based on the result of genearting the preview.
  //! @note The application should call **vdkPointCloud_Unload** with `ppCloud` to destroy the object once it's no longer needed.
  //!
  VDKDLL_API enum vdkError vdkConvert_GeneratePreview(struct vdkConvertContext *pConvertContext, struct vdkPointCloud **ppCloud);

#ifdef __cplusplus
}
#endif

#endif // vdkConvert_h__
