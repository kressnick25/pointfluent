import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udSdkLib.dart';

import './util/ArrayHelper.dart';

class UdRenderContext extends UdSDKClass {
  Pointer<IntPtr> _renderContext;
  udRenderInstance renderInstance;
  udRenderSettings renderSettings;
  udRenderPicking renderPicking;

  UdRenderContext() {
    this._renderContext = allocate();
    // These are allocated for nested structs
    this.renderInstance = udRenderInstance.allocate();
    this.renderPicking = udRenderPicking.allocate();
  }

  Pointer get address => _renderContext;

  /// Create an instance of `udRenderContext` for rendering
  void create(UdContext udContext) {
    handleUdError(_udRenderContext_Create(
        udContext.address, Pointer.fromAddress(_renderContext.address)));
  }

  /// Destroy the instance of the renderer
  void destroy() {
    handleUdError(
        _udRenderContext_Destroy(Pointer.fromAddress(_renderContext.address)));
  }

  /// Render the models from the persepective of `pRenderView`
  void render(UdRenderTarget renderTarget, int modelCount) {
    handleUdError(_udRenderContext_Render(
        _renderContext,
        renderTarget.addressOf,
        renderInstance.addressOf,
        modelCount,
        renderSettings.addressOf));
  }

  void cleanup() {
    free(_renderContext);
    free(renderInstance.addressOf);
    free(renderSettings.addressOf);
  }
}

/// These are various point modes available in udSDK
enum udRenderContextPointMode {
  udRCPM_Rectangles, //!< This is the default, renders the voxels expanded as screen space rectangles
  udRCPM_Cubes, //!< Renders the voxels as cubes
  udRCPM_Points, //!< Renders voxels as a single point (Note: does not accurately reflect the 'size' of voxels)

  udRCPM_Count //!< Total number of point modes. Used internally but can be used as an iterator max when displaying different point modes.
}

/// These are various render flags available
abstract class udRenderContextFlags {
  //!< Render the points using the default configuration.
  static const int udRCF_None = 0;
  //!< The colour and depth buffers won't be cleared before drawing and existing depth will be respected
  static const int udRCF_PreserveBuffers = 1 << 0;
  //!< This flag is required in some scenes where there is a very large amount of intersecting point clouds
  //!< It will internally batch rendering with the udRCF_PreserveBuffers flag after the first render.
  static const int udRCF_ComplexIntersections = 1 << 1;
  //!< This forces the streamer to load as much of the pointcloud as required to give an accurate representation in the current view. A small amount of further refinement may still occur.
  static const int udRCF_BlockingStreaming = 1 << 2;
  //!< Calculate the depth as a logarithmic distribution.
  static const int udRCF_LogarithmicDepth = 1 << 3;
  //!< The streamer won't be updated internally but a render call without this flag or a manual streamer update will be required
  static const int udRCF_ManualStreamerUpdate = 1 << 4;
}

/// Stores both the input and output of the udSDK picking system
class udRenderPicking extends Struct {
  // Input vars
  @Uint64()
  int x; //!< Mouse X position in udRenderTarget space
  @Uint64()
  int y; //!< Mouse Y position in udRenderTarget space

  // Output vars
  @Uint32()
  int hit; //!< Not 0 if a voxel was hit by this pick
  @Uint32()
  int isHighestLOD; //!< Not 0 if this voxel that was hit is as precise as possible
  @Uint64()
  int modelIndex; //!< Index of the model in the ppModels list
  @Double()
  double _pointCenter_0;
  @Double()
  double _pointCenter_1;
  @Double()
  double _pointCenter_2;

  //!< The center of the hit voxel in world space
  get pointCenter => _ArrayHelper_udRenderContext_pointCenter(this, [3], 0, 0);

  //!< The ID of the voxel that was hit by the pick; this ID is only valid for a very short period of time
  // Do any additional work using this ID this frame.
  Pointer<udVoxelID> voxelID;

  factory udRenderPicking.allocate() =>
      allocate<udRenderPicking>().ref..voxelID = allocate();
}

/// Stores the render settings used per render
class udRenderSettings extends Struct {
  //!< Optional flags providing information about how to perform this render
  @Int8()
  int flags; // enum udRenderContextFlags

  //!< Optional This provides information about the voxel under the mouse
  Pointer<udRenderPicking> pPick;

  //!< The point mode for this render
  @Int8()
  int pointMode; // enum udRenderContextPointMode

  //!< Optional This filter is applied to all models in the scene
  Pointer<udQueryFilter> pFilter;
}

class udRenderInstance extends Struct {
  //!< This is the point cloud to display
  Pointer<udPointCloud> pPointCloud;

  //!< The world space matrix for this point cloud instance (this does not to be the default matrix)
  //!< @note The default matrix for a model can be accessed from the associated udPointCloudHeader
  Pointer<Double> matrix;

  //!< Filter to override for this model, this one will be used instead of the global one applied in udRenderSettings
  Pointer<udQueryFilter> pFilter;

  //!< When the renderer goes to select a colour, it calls this function instead
  // uint32_t (*pVoxelShader)(struct udPointCloud *pPointCloud, const struct udVoxelID *pVoxelID, const void *pVoxelUserData);
  // TODO

  //!< If pVoxelShader is set, this parameter is passed to that function
  Pointer<Void> pVoxelUserData;

  List getMatrix() => matrix.asTypedList(16);

  void setMatrix(List values) {
    for (int i = 0; i < 16; i++) {
      matrix[i] = values[i];
    }
  }

  factory udRenderInstance.allocate() =>
      allocate<udRenderInstance>().ref..matrix = allocate(count: 16);
}

/// Helper for array `baseOffset` in struct `udPointCloudHeader`.
class _ArrayHelper_udRenderContext_pointCenter extends ArrayHelper {
  _ArrayHelper_udRenderContext_pointCenter(
      struct, dimensions, level, absoluteIndex)
      : super(struct, dimensions, level, absoluteIndex);

  operator [](int index) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        return struct._pointCenter_0;
      case 1:
        return struct._pointCenter_1;
      case 2:
        return struct._pointCenter_2;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }

  void operator []=(int index, value) {
    checkBounds(index);
    switch (absoluteIndex + index) {
      case 0:
        struct._pointCenter_0 = value;
        break;
      case 1:
        struct._pointCenter_1 = value;
        break;
      case 2:
        struct._pointCenter_2 = value;
        break;
      default:
        throw Exception('Invalid Array Helper generated.');
    }
  }
}

// udRenderContext_Create
// C declaration: udError udRenderContext_Create(struct udContext *pContext, struct udRenderContext **ppRenderer)
typedef _udRenderContext_Create_native = Int32 Function(
    Pointer, Pointer<IntPtr>);
typedef _udRenderContext_Create_dart = int Function(Pointer, Pointer<IntPtr>);
final _udRenderContext_CreatePointer =
    udSdkLib.lookup<NativeFunction<_udRenderContext_Create_native>>(
        'udRenderContext_Create');
final _udRenderContext_Create =
    _udRenderContext_CreatePointer.asFunction<_udRenderContext_Create_dart>();

// udRenderContext_Destroy
// C declaration: udError udRenderContext_Destroy(struct udRenderContext **ppRenderer)
typedef _udRenderContext_Destroy_native = Int32 Function(Pointer<IntPtr>);
typedef _udRenderContext_Destroy_dart = int Function(Pointer<IntPtr>);
final _udRenderContext_DestroyPointer =
    udSdkLib.lookup<NativeFunction<_udRenderContext_Destroy_native>>(
        'udRenderContext_Destroy');
final _udRenderContext_Destroy =
    _udRenderContext_DestroyPointer.asFunction<_udRenderContext_Destroy_dart>();

// udRenderContext_Render
// C declaration: udError udRenderContext_Render(struct udRenderContext *pRenderer, struct udRenderTarget *pRenderView, struct udRenderInstance *pModels, int modelCount, struct udRenderSettings *pRenderOptions);
typedef _udRenderContext_Render_native = Int32 Function(
    Pointer<IntPtr>,
    Pointer<udRenderTarget>,
    Pointer<udRenderInstance>,
    int,
    Pointer<udRenderSettings>);
typedef _udRenderContext_Render_dart = int Function(
    Pointer<IntPtr>,
    Pointer<udRenderTarget>,
    Pointer<udRenderInstance>,
    int,
    Pointer<udRenderSettings>);
final _udRenderContext_RenderPointer =
    udSdkLib.lookup<NativeFunction<_udRenderContext_Render_native>>(
        'udRenderContext_Render');
final _udRenderContext_Render =
    _udRenderContext_RenderPointer.asFunction<_udRenderContext_Render_dart>();