import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'udSdkLib.dart';

class UdAttributeSet extends UdSDKClass {
  udAttributeSet _attributeSet;
  UdAttributeSet() {
    this._attributeSet = udAttributeSet.allocate();
    assert(_attributeSet.allocated != null);
    assert(_attributeSet.content != null);
    assert(_attributeSet.count != null);

    assert(_attributeSet.pDescriptors != nullptr);
    assert(_attributeSet.pDescriptors[0].typeInfo != null);
    assert(_attributeSet.pDescriptors[0].blendType != null);
    assert(_attributeSet.pDescriptors[0].name[0] != null);
    assert(_attributeSet.pDescriptors[0].name[63] != null);

    cleanup();
  }

  Pointer<udAttributeSet> get address => _attributeSet.addressOf;

  /// Creates a udAttributeSet
  ///
  /// @param pAttributeSet The attribute set to allocate into
  /// @param content The standard attributes that will be created, provided as bitfields
  /// @param additionalCustomAttributes The count of additional attributes to generate, these will be added to the attribute set blank after the standard attributes
  /// @return A udError value based on the result of the creation of the attribute set.
  /// @note The application should call udAttributeSet_Free with pAttributeSet to destroy the object once it's no longer needed.
  ///
  void create(int udStdContent, int additionalCustomAttributes) {
    handleUdError(_udAttributeSet_Create(
        this.address, udStdContent, additionalCustomAttributes));
  }

  /// Free the memory created by a call to udAttributeSet_Generate
  ///
  /// @param pAttributeSet The attribute set to free the resources of
  /// @return A udError value based on the result of the destruction of the attribute set.
  void destroy() {
    handleUdError(_udAttributeSet_Destroy(this.address));
  }

  /// Gets the offset for a standard attribute so that further querying of that attribute can be performed
  ///
  /// `attribute` must be a value of the enum `udStdAttribute`
  int getOffsetOfStandardAttribute(int attribute) {
    final Pointer<Uint32> pOffset = allocate();
    try {
      handleUdError(_udAttributeSet_GetOffsetOfStandardAttribute(
          this.address, attribute, pOffset));
      return pOffset.value;
    } catch (err) {
      throw err;
    } finally {
      free(pOffset);
    }
  }

  /// Gets the offset for a standard attribute so that further querying of that attribute can be performed
  int getOffsetOfNamedAttribute(String name) {
    final Pointer<Uint32> pOffset = allocate();
    final pName = Utf8.toUtf8(name);
    try {
      handleUdError(_udAttributeSet_GetOffsetOfNamedAttribute(
          this.address, pName, pOffset));
      return pOffset.value;
    } catch (err) {
      throw err;
    } finally {
      free(pName);
      free(pOffset);
    }
  }

  void cleanup() {
    free(_attributeSet.pDescriptors);
    free(_attributeSet.addressOf);
  }
}

typedef _udAttributeSet_Create_native = Int32 Function(
    Pointer<Struct>, Int32, Uint32);
typedef _udAttributeSet_Create_dart = int Function(
    Pointer<udAttributeSet>, int, int);
final _udAttributeSet_CreatePointer =
    udSdkLib.lookup<NativeFunction<_udAttributeSet_Create_native>>(
        'udAttributeSet_Create');
final _udAttributeSet_Create =
    _udAttributeSet_CreatePointer.asFunction<_udAttributeSet_Create_dart>();

typedef _udAttributeSet_Destroy_native = Int32 Function(Pointer<Struct>);
typedef _udAttributeSet_Destroy_dart = int Function(Pointer<udAttributeSet>);
final _udAttributeSet_DestroyPointer =
    udSdkLib.lookup<NativeFunction<_udAttributeSet_Destroy_native>>(
        'udAttributeSet_Destroy');
final _udAttributeSet_Destroy =
    _udAttributeSet_DestroyPointer.asFunction<_udAttributeSet_Destroy_dart>();

typedef _udAttributeSet_GetOffsetOfStandardAttribute_native = Int32 Function(
    Pointer, Int32, Pointer<Uint32>);
typedef _udAttributeSet_GetOffsetOfStandardAttribute_dart = int Function(
    Pointer<udAttributeSet>, int, Pointer<Uint32>);
final _udAttributeSet_GetOffsetOfStandardAttributePointer = udSdkLib.lookup<
        NativeFunction<_udAttributeSet_GetOffsetOfStandardAttribute_native>>(
    'udAttributeSet_GetOffsetOfStandardAttribute');
final _udAttributeSet_GetOffsetOfStandardAttribute =
    _udAttributeSet_GetOffsetOfStandardAttributePointer
        .asFunction<_udAttributeSet_GetOffsetOfStandardAttribute_dart>();

typedef _udAttributeSet_GetOffsetOfNamedAttribute_native = Int32 Function(
    Pointer<Struct>, Pointer<Utf8>, Pointer<Uint32>);
typedef _udAttributeSet_GetOffsetOfNamedAttribute_dart = int Function(
    Pointer<udAttributeSet>, Pointer<Utf8>, Pointer<Uint32>);
final _udAttributeSet_GetOffsetOfNamedAttributePointer = udSdkLib
    .lookup<NativeFunction<_udAttributeSet_GetOffsetOfNamedAttribute_native>>(
        'udAttributeSet_GetOffsetOfNamedAttribute');
final _udAttributeSet_GetOffsetOfNamedAttribute =
    _udAttributeSet_GetOffsetOfNamedAttributePointer
        .asFunction<_udAttributeSet_GetOffsetOfNamedAttribute_dart>();

/// A list of standard UDS attributes
abstract class udStdAttribute {
  static const int udSA_GPSTime = 0;
  static const int udSA_PrimitiveID = 1;
  static const int udSA_ARGB = 2;
  static const int udSA_Normal = 3;
  static const int udSA_Intensity = 4;
  static const int udSA_NIR = 5;
  static const int udSA_ScanAngle = 6;
  static const int udSA_PointSourceID = 7;
  static const int udSA_Classification = 8;
  static const int udSA_ReturnNumber = 9;
  static const int udSA_NumberOfReturns = 10;
  static const int udSA_ClassificationFlags = 11;
  static const int udSA_ScannerChannel = 12;
  static const int udSA_ScanDirection = 13;
  static const int udSA_EdgeOfFlightLine = 14;
  static const int udSA_ScanAngleRank = 15;
  static const int udSA_LasUserData = 16; //!< Specific LAS User data field

  static const int udSA_Count = 17; //!< Count helper value to iterate this enum
  //!< Internal sentinal value used by some functions to indicate getting start of interleaved attributes
  static const int udSA_AllAttributes = udSA_Count;
  //!< Generally used to initialise an attribute value for use in loops
  static const int udSA_First = 0;
}

/// The standard UDS attributes provided as a bitfield
///
/// udStdAttributeContent enums are guaranteed to be 1 << associated udStdAttribute value
abstract class udStdAttributeContent {
  static const int udSAC_None = (0);
  static const int udSAC_GPSTime = (1 << udStdAttribute.udSA_GPSTime);
  static const int udSAC_PrimitiveID = (1 << udStdAttribute.udSA_PrimitiveID);
  static const int udSAC_ARGB = (1 << udStdAttribute.udSA_ARGB);
  static const int udSAC_Normal = (1 << udStdAttribute.udSA_Normal);
  static const int udSAC_Intensity = (1 << udStdAttribute.udSA_Intensity);
  static const int udSAC_NIR = (1 << udStdAttribute.udSA_NIR);
  static const int udSAC_ScanAngle = (1 << udStdAttribute.udSA_ScanAngle);
  static const int udSAC_PointSourceID =
      (1 << udStdAttribute.udSA_PointSourceID);
  static const int udSAC_Classification =
      (1 << udStdAttribute.udSA_Classification);
  static const int udSAC_ReturnNumber = (1 << udStdAttribute.udSA_ReturnNumber);
  static const int udSAC_NumberOfReturns =
      (1 << udStdAttribute.udSA_NumberOfReturns);
  static const int udSAC_ClassificationFlags =
      (1 << udStdAttribute.udSA_ClassificationFlags);
  static const int udSAC_ScannerChannel =
      (1 << udStdAttribute.udSA_ScannerChannel);
  static const int udSAC_ScanDirection =
      (1 << udStdAttribute.udSA_ScanDirection);
  static const int udSAC_EdgeOfFlightLine =
      (1 << udStdAttribute.udSA_EdgeOfFlightLine);
  static const int udSAC_ScanAngleRank =
      (1 << udStdAttribute.udSA_ScanAngleRank);
  static const int udSAC_LasUserData = (1 << udStdAttribute.udSA_LasUserData);

  static const int udSAC_AllAttributes =
      (1 << udStdAttribute.udSA_AllAttributes) - 1;
  static const int udSAC_64BitAttributes = udSAC_GPSTime;
  static const int udSAC_32BitAttributes =
      udSAC_PrimitiveID + udSAC_ARGB + udSAC_Normal;
  static const int udSAC_16BitAttributes =
      udSAC_Intensity + udSAC_NIR + udSAC_ScanAngle + udSAC_PointSourceID;
}

/// These are the various options for how an attribute is calculated when merging voxels while generating LODs
enum udAttributeBlendType {
  udABT_Mean, //!< This blend type merges nearby voxels together and finds the mean value for the attribute on those nodes
  udABT_FirstChild, //!< This blend type selects the value from one of the nodes and uses that
  udABT_NoLOD, //!< This blend type has no information in LODs and is only stored in the highest detail level

  udABT_Count //!< Total number of blend types. Used internally but can be used as an iterator max when checking attribute blend modes.
}

/// These are the types that could be contained in attributes
abstract class udAttributeTypeInfo {
  static const int udATI_Invalid = 0;
  // Lower 8 bits define the size in bytes - currently the actual maximum is 32
  static const int udATI_SizeMask = 0x000ff;
  static const int udATI_SizeShift = 0;
  // Next 8 bits define the number of components, component size is size/componentCount
  static const int udATI_ComponentCountMask = 0x0ff00;
  static const int udATI_ComponentCountShift = 8;
  // Set if type is signed (used in blend functions)
  static const int udATI_Signed = 0x10000;
  // Set if floating point type (signed should always be set)
  static const udATI_Float = 0x20000;
  // Set if type is de-quantized from a color
  static const udATI_Color = 0x40000;
  // Set if type is encoded normal (32 bit = 16:15:1)
  static const udATI_Normal = 0x80000;

  // Some keys to define standard types
  static const udATI_uint8 = 1;
  static const udATI_uint16 = 2;
  static const udATI_uint32 = 4;
  static const udATI_uint64 = 8;
  static const udATI_int8 = 1 | udATI_Signed;
  static const udATI_int16 = 2 | udATI_Signed;
  static const udATI_int32 = 4 | udATI_Signed;
  static const udATI_int64 = 8 | udATI_Signed;
  static const udATI_float32 = 4 | udATI_Signed | udATI_Float;
  static const udATI_float64 = 8 | udATI_Signed | udATI_Float;
  static const udATI_color32 = 4 | udATI_Color;
  static const udATI_normal32 = 4 | udATI_Normal;
  static const udATI_vec3f32 = 12 | 0x300 | udATI_Signed | udATI_Float;
}

/// Provides a set a attributes and includes an optimized lookup for standard types
class udAttributeSet extends Struct {
  /// Which standard attributes are available (used to optimize lookups internally), they still appear in the descriptors
  @Int32()
  int content;

  /// How many udAttributeDescriptor objects are used in pDescriptors
  @Uint32()
  int count;

  /// How many udAttributeDescriptor objects are allocated to be used in pDescriptors
  @Uint32()
  int allocated;

  // TODO properly allocate
  /// this contains the actual information on the attributes
  Pointer<udAttributeDescriptor> pDescriptors;

  factory udAttributeSet.allocate() =>
      allocate<udAttributeSet>().ref..pDescriptors = allocate();
}

/// Describes the contents of an attribute stream including its size, type and how it gets blended in LOD layers
class udAttributeDescriptor extends Struct {
  /// //!< This contains information about the type
  @Int32()
  int typeInfo;

  /// //!< Which blend type this attribute is using
  @Int32()
  int blendType;

  @Int8()
  int _unique_name_item_0;
  @Int8()
  int _unique_name_item_1;
  @Int8()
  int _unique_name_item_2;
  @Int8()
  int _unique_name_item_3;
  @Int8()
  int _unique_name_item_4;
  @Int8()
  int _unique_name_item_5;
  @Int8()
  int _unique_name_item_6;
  @Int8()
  int _unique_name_item_7;
  @Int8()
  int _unique_name_item_8;
  @Int8()
  int _unique_name_item_9;
  @Int8()
  int _unique_name_item_10;
  @Int8()
  int _unique_name_item_11;
  @Int8()
  int _unique_name_item_12;
  @Int8()
  int _unique_name_item_13;
  @Int8()
  int _unique_name_item_14;
  @Int8()
  int _unique_name_item_15;
  @Int8()
  int _unique_name_item_16;
  @Int8()
  int _unique_name_item_17;
  @Int8()
  int _unique_name_item_18;
  @Int8()
  int _unique_name_item_19;
  @Int8()
  int _unique_name_item_20;
  @Int8()
  int _unique_name_item_21;
  @Int8()
  int _unique_name_item_22;
  @Int8()
  int _unique_name_item_23;
  @Int8()
  int _unique_name_item_24;
  @Int8()
  int _unique_name_item_25;
  @Int8()
  int _unique_name_item_26;
  @Int8()
  int _unique_name_item_27;
  @Int8()
  int _unique_name_item_28;
  @Int8()
  int _unique_name_item_29;
  @Int8()
  int _unique_name_item_30;
  @Int8()
  int _unique_name_item_31;
  @Int8()
  int _unique_name_item_32;
  @Int8()
  int _unique_name_item_33;
  @Int8()
  int _unique_name_item_34;
  @Int8()
  int _unique_name_item_35;
  @Int8()
  int _unique_name_item_36;
  @Int8()
  int _unique_name_item_37;
  @Int8()
  int _unique_name_item_38;
  @Int8()
  int _unique_name_item_39;
  @Int8()
  int _unique_name_item_40;
  @Int8()
  int _unique_name_item_41;
  @Int8()
  int _unique_name_item_42;
  @Int8()
  int _unique_name_item_43;
  @Int8()
  int _unique_name_item_44;
  @Int8()
  int _unique_name_item_45;
  @Int8()
  int _unique_name_item_46;
  @Int8()
  int _unique_name_item_47;
  @Int8()
  int _unique_name_item_48;
  @Int8()
  int _unique_name_item_49;
  @Int8()
  int _unique_name_item_50;
  @Int8()
  int _unique_name_item_51;
  @Int8()
  int _unique_name_item_52;
  @Int8()
  int _unique_name_item_53;
  @Int8()
  int _unique_name_item_54;
  @Int8()
  int _unique_name_item_55;
  @Int8()
  int _unique_name_item_56;
  @Int8()
  int _unique_name_item_57;
  @Int8()
  int _unique_name_item_58;
  @Int8()
  int _unique_name_item_59;
  @Int8()
  int _unique_name_item_60;
  @Int8()
  int _unique_name_item_61;
  @Int8()
  int _unique_name_item_62;
  @Int8()
  int _unique_name_item_63;

  /// Helper for array `name`.
  ArrayHelper_udAttributeDescriptor_name_level0 get name =>
      ArrayHelper_udAttributeDescriptor_name_level0(this, [64], 0, 0);
}

/// Helper for array `name` in struct `udAttributeDescriptor`.
class ArrayHelper_udAttributeDescriptor_name_level0 {
  final udAttributeDescriptor _struct;
  final List<int> dimensions;
  final int level;
  final int _absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper_udAttributeDescriptor_name_level0(
      this._struct, this.dimensions, this.level, this._absoluteIndex);
  void _checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError(
          'Dimension $level: index not in range 0..${length} exclusive.');
    }
  }

  int operator [](int index) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        return _struct._unique_name_item_0;
      case 1:
        return _struct._unique_name_item_1;
      case 2:
        return _struct._unique_name_item_2;
      case 3:
        return _struct._unique_name_item_3;
      case 4:
        return _struct._unique_name_item_4;
      case 5:
        return _struct._unique_name_item_5;
      case 6:
        return _struct._unique_name_item_6;
      case 7:
        return _struct._unique_name_item_7;
      case 8:
        return _struct._unique_name_item_8;
      case 9:
        return _struct._unique_name_item_9;
      case 10:
        return _struct._unique_name_item_10;
      case 11:
        return _struct._unique_name_item_11;
      case 12:
        return _struct._unique_name_item_12;
      case 13:
        return _struct._unique_name_item_13;
      case 14:
        return _struct._unique_name_item_14;
      case 15:
        return _struct._unique_name_item_15;
      case 16:
        return _struct._unique_name_item_16;
      case 17:
        return _struct._unique_name_item_17;
      case 18:
        return _struct._unique_name_item_18;
      case 19:
        return _struct._unique_name_item_19;
      case 20:
        return _struct._unique_name_item_20;
      case 21:
        return _struct._unique_name_item_21;
      case 22:
        return _struct._unique_name_item_22;
      case 23:
        return _struct._unique_name_item_23;
      case 24:
        return _struct._unique_name_item_24;
      case 25:
        return _struct._unique_name_item_25;
      case 26:
        return _struct._unique_name_item_26;
      case 27:
        return _struct._unique_name_item_27;
      case 28:
        return _struct._unique_name_item_28;
      case 29:
        return _struct._unique_name_item_29;
      case 30:
        return _struct._unique_name_item_30;
      case 31:
        return _struct._unique_name_item_31;
      case 32:
        return _struct._unique_name_item_32;
      case 33:
        return _struct._unique_name_item_33;
      case 34:
        return _struct._unique_name_item_34;
      case 35:
        return _struct._unique_name_item_35;
      case 36:
        return _struct._unique_name_item_36;
      case 37:
        return _struct._unique_name_item_37;
      case 38:
        return _struct._unique_name_item_38;
      case 39:
        return _struct._unique_name_item_39;
      case 40:
        return _struct._unique_name_item_40;
      case 41:
        return _struct._unique_name_item_41;
      case 42:
        return _struct._unique_name_item_42;
      case 43:
        return _struct._unique_name_item_43;
      case 44:
        return _struct._unique_name_item_44;
      case 45:
        return _struct._unique_name_item_45;
      case 46:
        return _struct._unique_name_item_46;
      case 47:
        return _struct._unique_name_item_47;
      case 48:
        return _struct._unique_name_item_48;
      case 49:
        return _struct._unique_name_item_49;
      case 50:
        return _struct._unique_name_item_50;
      case 51:
        return _struct._unique_name_item_51;
      case 52:
        return _struct._unique_name_item_52;
      case 53:
        return _struct._unique_name_item_53;
      case 54:
        return _struct._unique_name_item_54;
      case 55:
        return _struct._unique_name_item_55;
      case 56:
        return _struct._unique_name_item_56;
      case 57:
        return _struct._unique_name_item_57;
      case 58:
        return _struct._unique_name_item_58;
      case 59:
        return _struct._unique_name_item_59;
      case 60:
        return _struct._unique_name_item_60;
      case 61:
        return _struct._unique_name_item_61;
      case 62:
        return _struct._unique_name_item_62;
      case 63:
        return _struct._unique_name_item_63;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, int value) {
    _checkBounds(index);
    switch (_absoluteIndex + index) {
      case 0:
        _struct._unique_name_item_0 = value;
        break;
      case 1:
        _struct._unique_name_item_1 = value;
        break;
      case 2:
        _struct._unique_name_item_2 = value;
        break;
      case 3:
        _struct._unique_name_item_3 = value;
        break;
      case 4:
        _struct._unique_name_item_4 = value;
        break;
      case 5:
        _struct._unique_name_item_5 = value;
        break;
      case 6:
        _struct._unique_name_item_6 = value;
        break;
      case 7:
        _struct._unique_name_item_7 = value;
        break;
      case 8:
        _struct._unique_name_item_8 = value;
        break;
      case 9:
        _struct._unique_name_item_9 = value;
        break;
      case 10:
        _struct._unique_name_item_10 = value;
        break;
      case 11:
        _struct._unique_name_item_11 = value;
        break;
      case 12:
        _struct._unique_name_item_12 = value;
        break;
      case 13:
        _struct._unique_name_item_13 = value;
        break;
      case 14:
        _struct._unique_name_item_14 = value;
        break;
      case 15:
        _struct._unique_name_item_15 = value;
        break;
      case 16:
        _struct._unique_name_item_16 = value;
        break;
      case 17:
        _struct._unique_name_item_17 = value;
        break;
      case 18:
        _struct._unique_name_item_18 = value;
        break;
      case 19:
        _struct._unique_name_item_19 = value;
        break;
      case 20:
        _struct._unique_name_item_20 = value;
        break;
      case 21:
        _struct._unique_name_item_21 = value;
        break;
      case 22:
        _struct._unique_name_item_22 = value;
        break;
      case 23:
        _struct._unique_name_item_23 = value;
        break;
      case 24:
        _struct._unique_name_item_24 = value;
        break;
      case 25:
        _struct._unique_name_item_25 = value;
        break;
      case 26:
        _struct._unique_name_item_26 = value;
        break;
      case 27:
        _struct._unique_name_item_27 = value;
        break;
      case 28:
        _struct._unique_name_item_28 = value;
        break;
      case 29:
        _struct._unique_name_item_29 = value;
        break;
      case 30:
        _struct._unique_name_item_30 = value;
        break;
      case 31:
        _struct._unique_name_item_31 = value;
        break;
      case 32:
        _struct._unique_name_item_32 = value;
        break;
      case 33:
        _struct._unique_name_item_33 = value;
        break;
      case 34:
        _struct._unique_name_item_34 = value;
        break;
      case 35:
        _struct._unique_name_item_35 = value;
        break;
      case 36:
        _struct._unique_name_item_36 = value;
        break;
      case 37:
        _struct._unique_name_item_37 = value;
        break;
      case 38:
        _struct._unique_name_item_38 = value;
        break;
      case 39:
        _struct._unique_name_item_39 = value;
        break;
      case 40:
        _struct._unique_name_item_40 = value;
        break;
      case 41:
        _struct._unique_name_item_41 = value;
        break;
      case 42:
        _struct._unique_name_item_42 = value;
        break;
      case 43:
        _struct._unique_name_item_43 = value;
        break;
      case 44:
        _struct._unique_name_item_44 = value;
        break;
      case 45:
        _struct._unique_name_item_45 = value;
        break;
      case 46:
        _struct._unique_name_item_46 = value;
        break;
      case 47:
        _struct._unique_name_item_47 = value;
        break;
      case 48:
        _struct._unique_name_item_48 = value;
        break;
      case 49:
        _struct._unique_name_item_49 = value;
        break;
      case 50:
        _struct._unique_name_item_50 = value;
        break;
      case 51:
        _struct._unique_name_item_51 = value;
        break;
      case 52:
        _struct._unique_name_item_52 = value;
        break;
      case 53:
        _struct._unique_name_item_53 = value;
        break;
      case 54:
        _struct._unique_name_item_54 = value;
        break;
      case 55:
        _struct._unique_name_item_55 = value;
        break;
      case 56:
        _struct._unique_name_item_56 = value;
        break;
      case 57:
        _struct._unique_name_item_57 = value;
        break;
      case 58:
        _struct._unique_name_item_58 = value;
        break;
      case 59:
        _struct._unique_name_item_59 = value;
        break;
      case 60:
        _struct._unique_name_item_60 = value;
        break;
      case 61:
        _struct._unique_name_item_61 = value;
        break;
      case 62:
        _struct._unique_name_item_62 = value;
        break;
      case 63:
        _struct._unique_name_item_63 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}
