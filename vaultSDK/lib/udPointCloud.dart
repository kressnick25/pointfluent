import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'udSdkLib.dart';
import 'udAttributes.dart';
import './util/ArrayHelper.dart';
import 'udContext.dart';

class UdPointCloud extends UdSDKClass {
  Pointer<IntPtr> _pointCloud;
  udPointCloudHeader header;

  UdPointCloud() {
    this._pointCloud = allocate();
    this.header = udPointCloudHeader.allocate();
    _nullChecks();
    setMounted();
  }

  int get address {
    checkMounted();
    return this._pointCloud[0];
  }

  void load(UdContext udContext, String modelLocation) {
    checkMounted();
    final pModelLocation = Utf8.toUtf8(modelLocation);
    final err = _udPointCloud_Load(udContext.address, this._pointCloud,
        pModelLocation, this.header.addressOf);
    free(pModelLocation);

    handleUdError(err);
  }

  void unLoad() {
    checkMounted();
    handleUdError(_udPointCloud_Unload(this._pointCloud));
  }

  void getHeader(UdContext udContext) {
    checkMounted();
    handleUdError(
        _udPointCloud_GetHeader(udContext.address, this.header.addressOf));
  }

  //udError getMetaData() {}

  void dispose() {
    checkMounted();
    free(this._pointCloud);
    free(this.header.attributes[0].pDescriptors);
    free(this.header.addressOf);
    super.dispose();
  }

  void _nullChecks() {
    assert(_pointCloud.cast() != nullptr);
    assert(header.attributes.cast() != nullptr);
    assert(header.scaledRange != null);
    assert(header.convertedResolution != null);
    assert(header.totalLODLayers != null);
    assert(header.unitMeterScale != null);
    assert(header.storedMatrix != null);
    assert(header.baseOffset != null);
    assert(header.boundingBoxCenter != null);
    assert(header.boundingBoxExtents != null);
    assert(header.pivot != null);
  }
}

/// Stores the internal state of a udSDK pointcloud
///
/// Can just use IntPtr instead
class udPointCloud extends Struct {}

class udQueryFilter extends Struct {}

class udVoxelID extends Struct {
  @Uint64()
  int index; //!< Internal index value

  Pointer<Void> pTrav; //!< Internal traverse info

  Pointer<Void> pRenderInfo; //!< Internal render info

  factory udVoxelID.allocate() => allocate<udVoxelID>().ref
    ..pTrav = allocate()
    ..pRenderInfo = allocate();
}

/// Stores basic information about a `udPointCloud`
class udPointCloudHeader extends Struct {
  @Double()
  double scaledRange; //!< The point cloud's range multiplied by the voxel size
  @Double()
  double
      unitMeterScale; //!< The scale to apply to convert to/from metres (after scaledRange is applied to the unitCube)
  @Uint32()
  int totalLODLayers; //!< The total number of LOD layers in this octree
  @Double()
  double convertedResolution; //!< The resolution this model was converted at

  // The attributes contained in this pointcloud
  Pointer<udAttributeSet> attributes;

  @Double()
  double _storedMatrix_0;
  @Double()
  double _storedMatrix_1;
  @Double()
  double _storedMatrix_2;
  @Double()
  double _storedMatrix_3;
  @Double()
  double _storedMatrix_4;
  @Double()
  double _storedMatrix_5;
  @Double()
  double _storedMatrix_6;
  @Double()
  double _storedMatrix_7;
  @Double()
  double _storedMatrix_8;
  @Double()
  double _storedMatrix_9;
  @Double()
  double _storedMatrix_10;
  @Double()
  double _storedMatrix_11;
  @Double()
  double _storedMatrix_12;
  @Double()
  double _storedMatrix_13;
  @Double()
  double _storedMatrix_14;
  @Double()
  double _storedMatrix_15;

  //!< The offset to the root of the pointcloud in unit cube space
  @Double()
  double _baseOffset_0;
  @Double()
  double _baseOffset_1;
  @Double()
  double _baseOffset_2;

  //!< The pivot point of the model, in unit cube space
  @Double()
  double _pivot_0;
  @Double()
  double _pivot_1;
  @Double()
  double _pivot_2;

  //!< The center of the bounding volume, in unit cube space
  @Double()
  double _boundingBoxCenter_0;
  @Double()
  double _boundingBoxCenter_1;
  @Double()
  double _boundingBoxCenter_2;

  //!< The extents of the bounding volume, in unit cube space
  @Double()
  double _boundingBoxExtents_0;
  @Double()
  double _boundingBoxExtents_1;
  @Double()
  double _boundingBoxExtents_2;

  // Nested struct workaround as here:
  // https://github.com/dart-lang/sdk/blob/master/samples/ffi/coordinate.dart#L18-L19
  factory udPointCloudHeader.allocate() => allocate<udPointCloudHeader>().ref
    ..attributes = udAttributeSet.allocate().addressOf;

  // factory udPointCloudHeader.allocate({
  //   double scaledRange,
  //   double unitMeterScale,
  //   int totalLODLayers,
  //   double convertedResolution,
  //   Pointer<udAttributeSet> attributes,
  //   List<double> storedMatrix,
  //   List<double> baseOffset,
  //   List<double> pivot,
  //   List<double> boundingBoxCenter,
  //   List<double> boudingBoxExtents,
  // }) {
  //   return allocate<udPointCloudHeader>().ref
  //     ..scaledRange = scaledRange
  //     ..unitMeterScale = unitMeterScale
  //     ..totalLODLayers = totalLODLayers
  //     ..convertedResolution = convertedResolution
  //     ..attributes
  //     .._baseOffset_0 = baseOffset[0]
  //     .._baseOffset_1 = baseOffset[1]
  //     .._baseOffset_2 = baseOffset[2]
  //     .._pivot_0 = pivot[0]
  //     .._pivot_1 = pivot[1]
  //     .._pivot_2 = pivot[2]
  //     .._boundingBoxCenter_0 = boundingBoxCenter[0]
  //     .._boundingBoxCenter_1 = boundingBoxCenter[1]
  //     .._boundingBoxCenter_2 = boundingBoxCenter[2]
  //     .._boundingBoxExtents_0 = boundingBoxCenter[0]
  //     .._boundingBoxExtents_1 = boundingBoxCenter[1]
  //     .._boundingBoxExtents_2 = boundingBoxCenter[2]
  //     .._storedMatrix_1 = 0
  //     .._storedMatrix_1 = storedMatrix[1]
  //     .._storedMatrix_2 = storedMatrix[2]
  //     .._storedMatrix_3 = storedMatrix[3]
  //     .._storedMatrix_4 = storedMatrix[4]
  //     .._storedMatrix_5 = storedMatrix[5]
  //     .._storedMatrix_6 = storedMatrix[6]
  //     .._storedMatrix_7 = storedMatrix[7]
  //     .._storedMatrix_8 = storedMatrix[8]
  //     .._storedMatrix_9 = storedMatrix[9]
  //     .._storedMatrix_10 = storedMatrix[10]
  //     .._storedMatrix_11 = storedMatrix[11]
  //     .._storedMatrix_12 = storedMatrix[12]
  //     .._storedMatrix_13 = storedMatrix[13]
  //     .._storedMatrix_14 = storedMatrix[14]
  //     .._storedMatrix_15 = storedMatrix[15];
  // }

  get storedMatrix =>
      _ArrayHelper_udPointCloudHeader_storedMatrix(this, [3], 0, 0);

  get baseOffset => _ArrayHelper_udPointCloudHeader_baseOffset(this, [3], 0, 0);

  get pivot => _ArrayHelper_udPointCloudHeader_pivot(this, [3], 0, 0);

  get boundingBoxCenter =>
      _ArrayHelper_udPointCloudHeader_boundingBoxCenter(this, [3], 0, 0);

  get boundingBoxExtents =>
      _ArrayHelper_udPointCloudHeader_boundingBoxExtents(this, [3], 0, 0);
}

/// Helper for array `storedMatrix` in struct `udPointCloudHeader`.
class _ArrayHelper_udPointCloudHeader_storedMatrix extends ArrayHelper {
  _ArrayHelper_udPointCloudHeader_storedMatrix(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._storedMatrix_0;
      case 1:
        return struct._storedMatrix_1;
      case 2:
        return struct._storedMatrix_2;
      case 3:
        return struct._storedMatrix_3;
      case 4:
        return struct._storedMatrix_4;
      case 5:
        return struct._storedMatrix_5;
      case 6:
        return struct._storedMatrix_6;
      case 7:
        return struct._storedMatrix_7;
      case 8:
        return struct._storedMatrix_8;
      case 9:
        return struct._storedMatrix_9;
      case 10:
        return struct._storedMatrix_10;
      case 11:
        return struct._storedMatrix_11;
      case 12:
        return struct._storedMatrix_12;
      case 13:
        return struct._storedMatrix_13;
      case 14:
        return struct._storedMatrix_14;
      case 15:
        return struct._storedMatrix_15;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._storedMatrix_0 = value;
        break;
      case 1:
        struct._storedMatrix_1 = value;
        break;
      case 2:
        struct._storedMatrix_2 = value;
        break;
      case 3:
        struct._storedMatrix_3 = value;
        break;
      case 4:
        struct._storedMatrix_4 = value;
        break;
      case 5:
        struct._storedMatrix_5 = value;
        break;
      case 6:
        struct._storedMatrix_6 = value;
        break;
      case 7:
        struct._storedMatrix_7 = value;
        break;
      case 8:
        struct._storedMatrix_8 = value;
        break;
      case 9:
        struct._storedMatrix_9 = value;
        break;
      case 10:
        struct._storedMatrix_10 = value;
        break;
      case 11:
        struct._storedMatrix_11 = value;
        break;
      case 12:
        struct._storedMatrix_12 = value;
        break;
      case 13:
        struct._storedMatrix_13 = value;
        break;
      case 14:
        struct._storedMatrix_14 = value;
        break;
      case 15:
        struct._storedMatrix_15 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `baseOffset` in struct `udPointCloudHeader`.
class _ArrayHelper_udPointCloudHeader_baseOffset extends ArrayHelper {
  _ArrayHelper_udPointCloudHeader_baseOffset(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._baseOffset_0;
      case 1:
        return struct._baseOffset_1;
      case 2:
        return struct._baseOffset_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._baseOffset_0 = value;
        break;
      case 1:
        struct._baseOffset_1 = value;
        break;
      case 2:
        struct._baseOffset_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `pivot` in struct `udPointCloudHeader`.
class _ArrayHelper_udPointCloudHeader_pivot extends ArrayHelper {
  _ArrayHelper_udPointCloudHeader_pivot(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._pivot_0;
      case 1:
        return struct._pivot_1;
      case 2:
        return struct._pivot_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._pivot_0 = value;
        break;
      case 1:
        struct._pivot_1 = value;
        break;
      case 2:
        struct._pivot_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `boundingBoxCenter` in struct `udPointCloudHeader`.
class _ArrayHelper_udPointCloudHeader_boundingBoxCenter extends ArrayHelper {
  _ArrayHelper_udPointCloudHeader_boundingBoxCenter(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._boundingBoxCenter_0;
      case 1:
        return struct._boundingBoxCenter_1;
      case 2:
        return struct._boundingBoxCenter_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._boundingBoxCenter_0 = value;
        break;
      case 1:
        struct._boundingBoxCenter_1 = value;
        break;
      case 2:
        struct._boundingBoxCenter_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

/// Helper for array `boundingBoxExtends` in struct `udPointCloudHeader`.
class _ArrayHelper_udPointCloudHeader_boundingBoxExtents extends ArrayHelper {
  _ArrayHelper_udPointCloudHeader_boundingBoxExtents(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._boundingBoxExtents_0;
      case 1:
        return struct._boundingBoxExtents_1;
      case 2:
        return struct._boundingBoxExtents_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._boundingBoxExtents_0 = value;
        break;
      case 1:
        struct._boundingBoxExtents_1 = value;
        break;
      case 2:
        struct._boundingBoxExtents_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

// udPointCloud_Load
//!
//! Load a udPointCloud from `modelLocation`.
//!
//! @param pContext The context to be used to load the model.
//! @param ppModel The pointer pointer of the udPointCloud. This will allocate an instance of `udPointCloud` into `ppModel`.
//! @param modelLocation The location to load the model from. This may be a file location, or a supported protocol (HTTP, HTTPS, FTP).
//! @param pHeader If non-null, the provided udPointCloudHeader structure will be writen to
//! @return A udError value based on the result of the model load.
//! @note The application should call **udPointCloud_Unload** with `ppModel` to destroy the object once it's no longer needed.
//!
typedef _udPointCloud_Load_native = Int32 Function(
    IntPtr, Pointer<IntPtr>, Pointer<Utf8>, Pointer<Struct>);
typedef _udPointCloud_Load_dart = int Function(
    int, Pointer<IntPtr>, Pointer<Utf8>, Pointer<udPointCloudHeader>);
final _udPointCloud_LoadPointer = udSdkLib
    .lookup<NativeFunction<_udPointCloud_Load_native>>('udPointCloud_Load');
final _udPointCloud_Load =
    _udPointCloud_LoadPointer.asFunction<_udPointCloud_Load_dart>();

// udPointCloud_Unload
//!
//! Destroys the udPointCloud.
//!
//! @param ppModel The pointer pointer of the udPointCloud. This will deallocate any internal memory used. It may take a few frames before the streamer releases the internal memory.
//! @return A udError value based on the result of the model unload.
//! @note The value of `ppModel` will be set to `NULL`.
//!
typedef _udPointCloud_Unload_native = Int32 Function(Pointer<IntPtr>);
typedef _udPointCloud_Unload_dart = int Function(Pointer<IntPtr>);
final _udPointCloud_UnloadPointer = udSdkLib
    .lookup<NativeFunction<_udPointCloud_Unload_native>>('udPointCloud_Unload');
final _udPointCloud_Unload =
    _udPointCloud_UnloadPointer.asFunction<_udPointCloud_Unload_dart>();

// udPointCloud_GetHeader
//!
//! Get the matrix of this model.
//!
//! @param pPointCloud The point cloud model to get the matrix from.
//! @param pHeader The header structure to fill out
//! @return A udError value based on the result of getting the model header.
//! @note All Unlimited Detail models are assumed to be from { 0, 0, 0 } to { 1, 1, 1 }. Any scaling applied to the model will be in this matrix along with the translation and rotation.
//!
typedef _udPointCloud_GetHeader_native = Int32 Function(
    IntPtr, Pointer<Struct>);
typedef _udPointCloud_GetHeader_dart = int Function(
    int, Pointer<udPointCloudHeader>);
final _udPointCloud_GetHeaderPointer =
    udSdkLib.lookup<NativeFunction<_udPointCloud_GetHeader_native>>(
        'udPointCloud_GetHeader');
final _udPointCloud_GetHeader =
    _udPointCloud_GetHeaderPointer.asFunction<_udPointCloud_GetHeader_dart>();
