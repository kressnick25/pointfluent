#ifndef vdkProject_h__
#define vdkProject_h__

//! @file vdkProject.h
//! The vdkProject and vdkProjectNode objects provide an interface for storing and syncronising geolocated projects between VDK sessions
//! @note The GeoJSON provided by this implementation is not fully compliant with RFC7946
//! @warning Antimeridian Cutting (Section 3.1.9) and handling the poles (Secion 5.3) are not fully working in this implementation
//! @warning This module does not currently expose the functionality to sync with the server. This will be added in a future release.

#include "vdkDLLExport.h"
#include "vdkError.h"
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

  struct vdkContext;

  //!
  //! @struct vdkProject
  //! Stores the internal state of the project
  //!
  struct vdkProject;

  //!
  //! @struct vdkInternalProjectNode
  //! Stores the internal state of a vdkProjectNode
  //!
  struct vdkInternalProjectNode;

  //!
  //! These are the geometry types for nodes
  //!
  enum vdkProjectGeometryType
  {
    vdkPGT_None, //!< There is no geometry associated with this node

    vdkPGT_Point, //!< pCoordinates is a single 3D position
    vdkPGT_MultiPoint, //!< Array of vdkPGT_Point, pCoordinates is an array of 3D positions
    vdkPGT_LineString, //!< pCoordinates is an array of 3D positions forming an open line
    vdkPGT_MultiLineString, //!< Array of vdkPGT_LineString; pCoordinates is NULL and children will be present
    vdkPGT_Polygon, //!< pCoordinates will be a closed linear ring (the outside), there MAY be children that are interior as pChildren vdkPGT_MultiLineString items, these should be counted as islands of the external ring.
    vdkPGT_MultiPolygon, //!< pCoordinates is null, children will be vdkPGT_Polygon (which still may have internal islands)
    vdkPGT_GeometryCollection, //!< Array of geometries; pCoordinates is NULL and children may be present of any type

    vdkPGT_Count, //!< Total number of geometry types. Used internally but can be used as an iterator max when displaying different type modes.

    vdkPGT_Internal, //!< Used internally when calculating other types. Do not use.
  };

  //!
  //! This represents the type of data stored in the node.
  //! @note The `itemtypeStr` in the vdkProjectNode is a string version. This enum serves to simplify the reading of standard types. The the string in brackets at the end of the comment is the string.
  //!
  enum vdkProjectNodeType
  {
    vdkPNT_Custom, //!< Need to check the itemtypeStr string manually

    vdkPNT_PointCloud, //!< A Euclideon Unlimited Detail Point Cloud file ("UDS")
    vdkPNT_PointOfInterest, //!< A point, line or region describing a location of interest ("POI")
    vdkPNT_Folder, //!< A folder of other nodes ("Folder")
    vdkPNT_LiveFeed, //!< A Euclideon Vault live feed container ("IOT")
    vdkPNT_Media, //!< An Image, Movie, Audio file or other media object ("Media")
    vdkPNT_Viewpoint, //!< An Camera Location & Orientation ("Camera")
    vdkPNT_VisualisationSettings, //!< Visualisation settings (itensity, map height etc) ("VizSet")

    vdkPNT_Count //!< Total number of node types. Used internally but can be used as an iterator max when displaying different type modes.
  };

  //!
  //! @struct vdkProjectNode
  //! Stores the state of a node.
  //! @warning This struct is exposed to avoid having a huge API of accessor functions but it should be treated as read only with the exception of `pUserData`. Making changes to the internal data will cause issues syncronising data
  //!
  struct vdkProjectNode
  {
    // Node header data
    char UUID[37]; //!< Unique identifier for this node "id"
    double lastUpdate; //!< The last time this node was updated in UTC

    enum vdkProjectNodeType itemtype; //!< The type of this node, see vdkProjectNodeType for more information
    char itemtypeStr[8]; //!< The string representing the type of node. If its a known type during node creation `itemtype` will be set to something other than vdkPNT_Custom

    const char *pName; //!< Human readable name of the item
    const char *pURI; //!< The address or filename that the resource can be found.

    bool hasBoundingBox; //!< Set to true if this nodes boundingBox item is filled out
    double boundingBox[6]; //!< The bounds of this model, ordered as [West, South, Floor, East, North, Ceiling]

    // Geometry Info
    enum vdkProjectGeometryType geomtype; //!< Indicates what geometry can be found in this model. See the vdkProjectGeometryType documentation for more information.
    int geomCount; //!< How many geometry items can be found on this model
    double *pCoordinates; //!< The positions of the geometry of this node (NULL this this node doesn't have points). The format is [X0,Y0,Z0,...Xn,Yn,Zn]

    // Next nodes
    struct vdkProjectNode *pNextSibling; //!< This is the next item in the project (NULL if no further siblings)
    struct vdkProjectNode *pFirstChild; //!< Some types ("folder", "collection", "polygon"...) have children nodes, NULL if there are no children.

    // Node Data
    void *pUserData; //!< This is application specific user data. The application should traverse the tree to release these before releasing the vdkProject
    struct vdkInternalProjectNode *pInternalData; //!< Internal VDK specific state for this node
  };

  //!
  //! Create an empty, local only, instance of `vdkProject`.
  //!
  //! @param ppProject The pointer pointer of the vdkProject. This will allocate an instance of vdkProject into `ppProject`.
  //! @param pName The name of the project, this will be the name of the root item.
  //! @return A vdkError value based on the result of the project creation.
  //!
  VDKDLL_API enum vdkError vdkProject_CreateLocal(struct vdkProject **ppProject, const char *pName);

  //!
  //! Create a local only instance of `vdkProject` filled in with the contents of a GeoJSON string.
  //!
  //! @param ppProject The pointer pointer of the vdkProject. This will allocate an instance of vdkProject into `ppProject`.
  //! @param pGeoJSON The GeoJSON string of the project, this will be unpacked into vdkProjectNode items.
  //! @return A vdkError value based on the result of the project creation.
  //!
  VDKDLL_API enum vdkError vdkProject_LoadFromMemory(struct vdkProject **ppProject, const char *pGeoJSON);

  //!
  //! Destroy the instance of the project.
  //!
  //! @param ppProject The pointer pointer of the vdkProject. This will deallocate the instance of the project as well as destroying all nodes.
  //! @return A vdkError value based on the result of the project destruction.
  //! @warning The pUserData item should be already released from every node before calling this.
  //!
  VDKDLL_API enum vdkError vdkProject_Release(struct vdkProject **ppProject);

  //!
  //! Export a project to a GeoJSON string in memory.
  //!
  //! @param pProject The pointer to a valid vdkProject that will be exported as GeoJSON.
  //! @param ppMemory The pointer pointer to a string that will contain the exported GeoJSON.
  //! @return A vdkError value based on the result of the project export.
  //! @warning The memory is stored in the vdkProject and subsequent calls will destroy older versions, the buffer is released when the project is released.
  //!
  VDKDLL_API enum vdkError vdkProject_WriteToMemory(struct vdkProject *pProject, const char **ppMemory);

  //!
  //! Get the project root node.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param ppRootNode The pointer pointer to a node that will contain the node. The node ownership still belongs to the pProject.
  //! @return A vdkError value based on the result of getting the root node.
  //! @note This node will always have itemtype of type vdkPNT_Folder and cannot (and will not) have sibling nodes.
  //! @note The name of the project is the name of the returned root node.
  //!
  VDKDLL_API enum vdkError vdkProject_GetProjectRoot(struct vdkProject *pProject, struct vdkProjectNode **ppRootNode);

  //!
  //! Create a node in a project
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param ppNode A pointer pointer to the node that will be created. This can be NULL if getting the node back isn't required.
  //! @param pParent The parent node of the item.
  //! @param pType The string representing the type of the item. This can be a defined string provided by vdkProject_GetTypeName or a custom type. Cannot be NULL.
  //! @param pName A human readable name for the item. If this item is NULL it will attempt to generate a name from the pURI or the pType strings.
  //! @param pURI The URL, filename or other URI containing where to find this item. These should be absolute paths where applicable (preferably HTTPS) to ensure maximum interop with other packages.
  //! @param pUserData A pointer to data provided by the application to store in the `pUserData` item in the vdkProjectNode.
  //! @return A vdkError value based on the result of the node being created in the project.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_Create(struct vdkProject *pProject, struct vdkProjectNode **ppNode, struct vdkProjectNode *pParent, const char *pType, const char *pName, const char *pURI, void *pUserData);

  //!
  //! Move a node to reorder within the current parent or move to a different parent.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param pCurrentParent The current parent of pNode.
  //! @param pNewParent The intended new parent of pNode.
  //! @param pNode The node to move.
  //! @param pInsertBeforeChild The node that will be after pNode after the move. Set as NULL to be the last child of pNewParent.
  //! @return A vdkError value based on the result of the move.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_MoveChild(struct vdkProject *pProject, struct vdkProjectNode *pCurrentParent, struct vdkProjectNode *pNewParent, struct vdkProjectNode *pNode, struct vdkProjectNode *pInsertBeforeChild);

  //!
  //! Remove a node from the project.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param pParentNode The parent of the node to be removed.
  //! @param pNode The node to remove from the project.
  //! @return A vdkError value based on the result of removing the node.
  //! @warning Ensure that the pUserData point of pNode has been released before calling this.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_RemoveChild(struct vdkProject *pProject, struct vdkProjectNode *pParentNode, struct vdkProjectNode *pNode);

  //!
  //! Set the human readable name of a node.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param pNode The node to change the name of.
  //! @param pNodeName The new name of the node. This is duplicated internally.
  //! @return A vdkError value based on the result of setting the name.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetName(struct vdkProject *pProject, struct vdkProjectNode *pNode, const char *pNodeName);

  //!
  //! Set the URI of a node.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param pNode The node to change the name of.
  //! @param pNodeURI The new URI of the node. This is duplicated internally.
  //! @return A vdkError value based on the result of setting the URI.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetURI(struct vdkProject *pProject, struct vdkProjectNode *pNode, const char *pNodeURI);

  //!
  //! Set the new geometry of a node.
  //!
  //! @param pProject The pointer to a valid vdkProject.
  //! @param pNode The node to change the name of.
  //! @param nodeType The new type of the geometry
  //! @param geometryCount How many coordinates are being added
  //! @param pCoordinates A pointer to the new coordinates (this is an array that should be 3x the length of geometryCount). Ordered in [ longitude0, latitude0, altitude0, ..., longitudeN, latitudeN, altitudeN ] order.
  //! @return A vdkError value based on the result of setting the geometry.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetGeometry(struct vdkProject *pProject, struct vdkProjectNode *pNode, enum vdkProjectGeometryType nodeType, int geometryCount, double *pCoordinates);

  //!
  //! Get a metadata item of a node as an integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pInt The pointer to the memory to write the metadata to
  //! @param defaultValue The value to write to pInt if the metadata item isn't in the vdkProjectNode or if it isn't of an integer type
  //! @return A vdkError value based on the result of reading the metadata into pInt.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataInt(struct vdkProjectNode *pNode, const char *pMetadataKey, int32_t *pInt, int32_t defaultValue);

  //!
  //! Set a metadata item of a node from an integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param iValue The integer value to write to the metadata key
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataInt(struct vdkProjectNode *pNode, const char *pMetadataKey, int32_t iValue);

  //!
  //! Get a metadata item of a node as an unsigned integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pInt The pointer to the memory to write the metadata to
  //! @param defaultValue The value to write to pInt if the metadata item isn't in the vdkProjectNode or if it isn't of an integer type
  //! @return A vdkError value based on the result of reading the metadata into pInt.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataUint(struct vdkProjectNode *pNode, const char *pMetadataKey, uint32_t *pInt, uint32_t defaultValue);

  //!
  //! Set a metadata item of a node from an unsigned integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param iValue The unsigned integer value to write to the metadata key
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataUint(struct vdkProjectNode *pNode, const char *pMetadataKey, uint32_t iValue);

  //!
  //! Get a metadata item of a node as a 64 bit integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pInt64 The pointer to the memory to write the metadata to
  //! @param defaultValue The value to write to pInt64 if the metadata item isn't in the vdkProjectNode or if it isn't of an integer type
  //! @return A vdkError value based on the result of reading the metadata into pInt64.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataInt64(struct vdkProjectNode *pNode, const char *pMetadataKey, int64_t *pInt64, int64_t defaultValue);

  //!
  //! Set a metadata item of a node from a 64 bit integer.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param i64Value The integer value to write to the metadata key
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataInt64(struct vdkProjectNode *pNode, const char *pMetadataKey, int64_t i64Value);

  //!
  //! Get a metadata item of a node as a double.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pDouble The pointer to the memory to write the metadata to
  //! @param defaultValue The value to write to pDouble if the metadata item isn't in the vdkProjectNode or if it isn't of an integer or floating point type
  //! @return A vdkError value based on the result of reading the metadata into pDouble.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataDouble(struct vdkProjectNode *pNode, const char *pMetadataKey, double *pDouble, double defaultValue);

  //!
  //! Set a metadata item of a node from a double.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param doubleValue The double value to write to the metadata key
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataDouble(struct vdkProjectNode *pNode, const char *pMetadataKey, double doubleValue);

  //!
  //! Get a metadata item of a node as an boolean.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pBool The pointer to the memory to write the metadata to
  //! @param defaultValue The value to write to pBool if the metadata item isn't in the vdkProjectNode or if it isn't of a boolean type
  //! @return A vdkError value based on the result of reading the metadata into pBool.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataBool(struct vdkProjectNode *pNode, const char *pMetadataKey, bool *pBool, bool defaultValue);

  //!
  //! Set a metadata item of a node from an boolean.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param boolValue The boolean value to write to the metadata key
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataBool(struct vdkProjectNode *pNode, const char *pMetadataKey, bool boolValue);

  //!
  //! Get a metadata item of a node as a string.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param ppString The pointer pointer to the memory of the string. This is owned by the vdkProjectNode and should be copied if required to be stored for a long period.
  //! @param pDefaultValue The value to write to ppString if the metadata item isn't in the vdkProjectNode or if it isn't of a string type
  //! @return A vdkError value based on the result of reading the metadata into ppString.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_GetMetadataString(struct vdkProjectNode *pNode, const char *pMetadataKey, const char **ppString, const char *pDefaultValue);

  //!
  //! Set a metadata item of a node from a string.
  //!
  //! @param pNode The node to get the metadata from.
  //! @param pMetadataKey The name of the metadata key.
  //! @param pString The string to write to the metadata key. This is duplicated internally.
  //! @return A vdkError value based on the result of writing the metadata into the node.
  //!
  VDKDLL_API enum vdkError vdkProjectNode_SetMetadataString(struct vdkProjectNode *pNode, const char *pMetadataKey, const char *pString);

  //!
  //! Get the standard type string name for an itemtype
  //!
  //! @param itemtype The vdkProjectNodeType value
  //! @return A string containing the standard name for the item in the vdkProjectNodeType enum. This is internal and should not be freed.
  //!
  VDKDLL_API const char* vdkProject_GetTypeName(enum vdkProjectNodeType itemtype); // Might return NULL

#ifdef __cplusplus
}
#endif

#endif // vdkProject_h__
