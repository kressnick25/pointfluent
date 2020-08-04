#ifndef vdkAttributes_h__
#define vdkAttributes_h__

//! @file vdkAttributes.h
//! vdkAttributes.h provides an interface to attribute streams of Unlimited Detail models.

#include <stdint.h>
#include "vdkDLLExport.h"
#include "vdkError.h"

#ifdef __cplusplus
extern "C" {
#endif

  //!
  //! A list of standard UDS attributes
  //!
  enum vdkStandardAttribute
  {
    vdkSA_GPSTime,
    vdkSA_ARGB,
    vdkSA_Normal,
    vdkSA_Intensity,
    vdkSA_NIR,
    vdkSA_ScanAngle,
    vdkSA_PointSourceID,
    vdkSA_Classification,
    vdkSA_ReturnNumber,
    vdkSA_NumberOfReturns,
    vdkSA_ClassificationFlags,
    vdkSA_ScannerChannel,
    vdkSA_ScanDirection,
    vdkSA_EdgeOfFlightLine,
    vdkSA_ScanAngleRank,
    vdkSA_LASUserData,

    vdkSA_Count
  };

  //!
  //! The standard UDS attributes provided as a bitfield
  //!
  enum vdkStandardAttributeContent
  {
    vdkSAC_None = (0),
    vdkSAC_GPSTime = (1 << vdkSA_GPSTime),
    vdkSAC_ARGB = (1 << vdkSA_ARGB),
    vdkSAC_Normal = (1 << vdkSA_Normal),
    vdkSAC_Intensity = (1 << vdkSA_Intensity),
    vdkSAC_NIR = (1 << vdkSA_NIR),
    vdkSAC_ScanAngle = (1 << vdkSA_ScanAngle),
    vdkSAC_PointSourceID = (1 << vdkSA_PointSourceID),
    vdkSAC_Classification = (1 << vdkSA_Classification),
    vdkSAC_ReturnNumber = (1 << vdkSA_ReturnNumber),
    vdkSAC_NumberOfReturns = (1 << vdkSA_NumberOfReturns),
    vdkSAC_ClassificationFlags = (1 << vdkSA_ClassificationFlags),
    vdkSAC_ScannerChannel = (1 << vdkSA_ScannerChannel),
    vdkSAC_ScanDirection = (1 << vdkSA_ScanDirection),
    vdkSAC_EdgeOfFlightLine = (1 << vdkSA_EdgeOfFlightLine),
    vdkSAC_ScanAngleRank = (1 << vdkSA_ScanAngleRank),
    vdkSAC_LasUserData = (1 << vdkSA_LASUserData),
  };

  //!
  //! These are the various options for how an attribute is calculated when merging voxels while generating LODs
  //!
  enum vdkAttributeBlendMode
  {
    vdkABM_Mean, //!< This mode merges nearby voxels together and finds the mean value for the attribute on those nodes
    vdkABM_SingleValue, //!< This mode selects the value from one of the nodes and uses that

    vdkABM_Count //!< Total number of blend modes. Used internally but can be used as an iterator max when checking attribute blend modes.
  };

  //!
  //! These are the types that could be contained in attributes
  //!
  enum vdkAttributeTypeInfo
  {
    vdkAttributeTypeInfo_Invalid = 0,
    vdkAttributeTypeInfo_SizeMask = 0x000ff,  // Lower 8 bits define the size in bytes - currently the actual maximum is 32
    vdkAttributeTypeInfo_SizeShift = 0,
    vdkAttributeTypeInfo_ComponentCountMask = 0x0ff00,  // Next 8 bits define the number of components, component size is size/componentCount
    vdkAttributeTypeInfo_ComponentCountShift = 8,
    vdkAttributeTypeInfo_Signed = 0x10000,  // Set if type is signed (used in blend functions)
    vdkAttributeTypeInfo_Float = 0x20000,  // Set if floating point type (signed should always be set)
    vdkAttributeTypeInfo_Color = 0x40000,  // Set if type is de-quantized from a color
    vdkAttributeTypeInfo_Normal = 0x80000,  // Set if type is encoded normal (32 bit = 16:15:1)

    // Some keys to define standard types
    vdkAttributeTypeInfo_uint8 = 1,
    vdkAttributeTypeInfo_uint16 = 2,
    vdkAttributeTypeInfo_uint32 = 4,
    vdkAttributeTypeInfo_uint64 = 8,
    vdkAttributeTypeInfo_int8 = 1 | vdkAttributeTypeInfo_Signed,
    vdkAttributeTypeInfo_int16 = 2 | vdkAttributeTypeInfo_Signed,
    vdkAttributeTypeInfo_int32 = 4 | vdkAttributeTypeInfo_Signed,
    vdkAttributeTypeInfo_int64 = 8 | vdkAttributeTypeInfo_Signed,
    vdkAttributeTypeInfo_float32 = 4 | vdkAttributeTypeInfo_Signed | vdkAttributeTypeInfo_Float,
    vdkAttributeTypeInfo_float64 = 8 | vdkAttributeTypeInfo_Signed | vdkAttributeTypeInfo_Float,
    vdkAttributeTypeInfo_color32 = 4 | vdkAttributeTypeInfo_Color,
    vdkAttributeTypeInfo_normal32 = 4 | vdkAttributeTypeInfo_Normal,
    vdkAttributeTypeInfo_vec3f32 = 12 | 0x300 | vdkAttributeTypeInfo_Signed | vdkAttributeTypeInfo_Float
  };

  //!
  //! @struct vdkAttributeDescriptor
  //! Describes the contents of an attribute stream including its size, type and how it gets blended in LOD layers
  //!
  struct vdkAttributeDescriptor
  {
    enum vdkAttributeTypeInfo typeInfo; //!< This contains information about the type
    enum vdkAttributeBlendMode blendMode; //!< Which blend mode this attribute is using
    char name[64]; //!< Name of the attibute
  };

  //!
  //! @struct vdkAttributeSet
  //! Provides a set a attributes and includes an optimized lookup for standard types
  //!
  struct vdkAttributeSet
  {
    enum vdkStandardAttributeContent standardContent; //!< Which standard attributes are available (used to optimize lookups internally), they still appear in the descriptors
    uint32_t count; //!< How many vdkAttributeDescriptor objects are used in pDescriptors
    uint32_t allocated; //!< How many vdkAttributeDescriptor objects are allocated to be used in pDescriptors
    struct vdkAttributeDescriptor *pDescriptors; //!< this contains the actual information on the attributes
  };

  //!
  //! Creates a vdkAttributeSet
  //!
  //! @param pAttributeSet The attribute set to allocate into
  //! @param standardContent The standard attributes that will be created, provided as bitfields
  //! @param additionalCustomAttributes The count of additional attributes to generate, these will be added to the attribute set blank after the standard attributes
  //! @return A vdkError value based on the result of the creation of the attribute set.
  //! @note The application should call vdkAttributeSet_Free with pAttributeSet to destroy the object once it's no longer needed.
  //!
  VDKDLL_API enum vdkError vdkAttributeSet_Generate(struct vdkAttributeSet *pAttributeSet, enum vdkStandardAttributeContent standardContent, uint32_t additionalCustomAttributes);

  //!
  //! Free the memory created by a call to vdkAttributeSet_Generate
  //!
  //! @param pAttributeSet The attribute set to free the resources of
  //! @return A vdkError value based on the result of the destruction of the attribute set.
  //!
  VDKDLL_API enum vdkError vdkAttributeSet_Free(struct vdkAttributeSet *pAttributeSet);

  //!
  //! Gets the offset for a standard attribute so that further querying of that attribute can be performed
  //!
  //! @param pAttributeSet The attribute set to get the offset for
  //! @param attribute The enum value of the attribute
  //! @param pOffset This pointer will be written to with the value of the offset if it is found
  //! @return A vdkError value based on the result of writing the offset to pOffset
  //!
  VDKDLL_API enum vdkError vdkAttributeSet_GetOffsetOfStandardAttribute(const struct vdkAttributeSet *pAttributeSet, enum vdkStandardAttribute attribute, uint32_t *pOffset);

  //!
  //! Gets the offset for a named attribute so that further querying of that attribute can be performed
  //!
  //! @param pAttributeSet The attribute set to get the offset for
  //! @param pName The name of the attribute
  //! @param pOffset This pointer will be written to with the value of the offset if it is found
  //! @return A vdkError value based on the result of writing the offset to pOffset
  //!
  VDKDLL_API enum vdkError vdkAttributeSet_GetOffsetOfNamedAttribute(const struct vdkAttributeSet *pAttributeSet, const char *pName, uint32_t *pOffset);

#ifdef __cplusplus
}
#endif //__cplusplus

#ifdef __cplusplus
// These helper operators for the enums are provided when using a C++ compiler
inline enum vdkStandardAttributeContent operator|(enum vdkStandardAttributeContent a, enum vdkStandardAttributeContent b) { return (enum vdkStandardAttributeContent)(int(a) | int(b)); }
inline enum vdkStandardAttributeContent operator&(enum vdkStandardAttributeContent a, enum vdkStandardAttributeContent b) { return (enum vdkStandardAttributeContent)(int(a) & int(b)); }
#endif //__cplusplus

#endif // vdkAttributes_h__
