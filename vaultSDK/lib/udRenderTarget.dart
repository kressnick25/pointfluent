import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udSdkLib.dart';

import './util/ArrayHelper.dart';

const int _cameraMatrixLength = 16;

class UdRenderTarget extends UdSDKClass {
  Pointer<IntPtr> _renderTarget;
  Pointer<Int64> _colorBuffer;
  Pointer<Float> _depthBuffer;
  final int width;
  final int height;
  final int _bufferLength;

  UdRenderTarget(this.width, this.height)
      : this._bufferLength = width * height {
    this._renderTarget = allocate();
    this._colorBuffer = allocate(count: _bufferLength);
    this._depthBuffer = allocate(count: _bufferLength);

    _nullChecks();
    setMounted();
  }

  int get address {
    checkMounted();
    return this._renderTarget[0];
  }

  Int64List get colorBuffer {
    checkMounted();
    return this._colorBuffer.asTypedList(_bufferLength);
  }

  Float32List get depthBuffer {
    checkMounted();
    return this._depthBuffer.asTypedList(_bufferLength);
  }

  /// Create a udRenderTarget with a viewport
  void create(UdContext udContext, UdRenderContext renderContext) {
    checkMounted();
    final ppRenderTarget =
        Pointer.fromAddress(_renderTarget.address).cast<IntPtr>();
    handleUdError(_udRenderTarget_Create(
      udContext.address,
      ppRenderTarget,
      renderContext.address,
      this.width,
      this.height,
    ));
  }

  /// Destroys the instance of `ppRenderTarget`.
  void destroy() {
    checkMounted();
    handleUdError(_udRenderTarget_Destroy(_renderTarget));
    this.dispose();
  }

  /// Set a memory buffers that a render target will write to.
  void setTargets({int colorClearValue = 0}) {
    checkMounted();
    final pColorBuffer = _colorBuffer;
    final pDepthBuffer = _depthBuffer;
    handleUdError(_udRenderTarget_SetTargets(
        _renderTarget[0], pColorBuffer, colorClearValue, pDepthBuffer));
  }

  /// Set a memory buffers that a render target will write to (with pitch).
  void setTargetsWithPitch(int colorPitchInBytes, int depthPitchInBytes,
      [int colorClearValue = 0]) {
    checkMounted();
    final pColorBuffer = _colorBuffer.cast<Void>();
    final pDepthBuffer = _depthBuffer.cast<Void>();
    handleUdError(_udRenderTarget_SetTargetsWithPitch(
        _renderTarget[0],
        pColorBuffer,
        colorClearValue,
        pDepthBuffer,
        colorPitchInBytes,
        depthPitchInBytes));
  }

  /// Get the matrix associated with `pRenderTarget` of type `matrixType` and fill it in `cameraMatrix`.
  List<double> getMatrix(udRenderTargetMatrix matrixType) {
    checkMounted();
    Pointer<Double> cameraMatrix = allocate(count: 16);
    try {
      handleUdError(_udRenderTarget_GetMatrix(
          _renderTarget[0], matrixType.index, cameraMatrix));
      return cameraMatrix.asTypedList(16);
    } catch (err) {
      throw err;
    } finally {
      free(cameraMatrix);
    }
  }

  // Set the matrix associated with `pRenderTarget` of type `matrixType` and get it from `cameraMatrix`.
  void setMatrix(udRenderTargetMatrix matrixType, List<double> cameraMatrix) {
    checkMounted();
    if (cameraMatrix.length != 16)
      throw new FormatException("cameraMatrix length must be 16");

    final matrix = doubleListToCArray(cameraMatrix);
    assert(_renderTarget != nullptr);
    try {
      handleUdError(_udRenderTarget_SetMatrix(
          _renderTarget[0], matrixType.index, matrix));
    } catch (err) {
      throw err;
    } finally {
      free(matrix);
    }
  }

  void dispose() {
    checkMounted();
    free(_renderTarget);
    free(_colorBuffer);
    free(_depthBuffer);
    super.dispose();
  }

  void _nullChecks() {
    assert(_renderTarget != nullptr);
    assert(_colorBuffer != nullptr);
    assert(_colorBuffer[0] != null);
    assert(_colorBuffer[_bufferLength] != null);
    assert(_depthBuffer != nullptr);
    assert(_depthBuffer[0] != null);
    assert(_depthBuffer[_bufferLength] != null);
  }
}

/// Stores the internal state of a udSDK render target
class udRenderTarget extends Struct {}

/// These are the various matrix types used within the render target
enum udRenderTargetMatrix {
  udRTM_Camera, //!< The local to world-space transform of the camera (View is implicitly set as the inverse)
  udRTM_View, //!< The view-space transform for the model (does not need to be set explicitly)
  udRTM_Projection, //!< The projection matrix (default is 60 degree LH)
  udRTM_Viewport, //!< Viewport scaling matrix (default width and height of viewport)

  udRTM_Count //!< Total number of matrix types. Used internally but can be used as an iterator max when checking matrix information.
}

// udRenderTarget_Create
// C declaration: udError udRenderTarget_Create(struct udContext *pContext, struct udRenderTarget **ppRenderTarget, struct udRenderContext *pRenderer, uint32_t width, uint32_t height);
typedef _udRenderTarget_Create_native = Int32 Function(
    IntPtr, Pointer<IntPtr>, IntPtr, Uint32, Uint32);
typedef _udRenderTarget_Create_dart = int Function(
    int, Pointer<IntPtr>, int, int, int);
final _udRenderTarget_CreatePointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_Create_native>>(
        'udRenderTarget_Create');
final _udRenderTarget_Create =
    _udRenderTarget_CreatePointer.asFunction<_udRenderTarget_Create_dart>();

// udRenderTarget_Destroy
// C declaration: enum udError udRenderTarget_Destroy(struct udRenderTarget **ppRenderTarget);
typedef _udRenderTarget_Destroy_native = Int32 Function(Pointer<IntPtr>);
typedef _udRenderTarget_Destroy_dart = int Function(Pointer<IntPtr>);
final _udRenderTarget_DestroyPointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_Destroy_native>>(
        'udRenderTarget_Destroy');
final _udRenderTarget_Destroy =
    _udRenderTarget_DestroyPointer.asFunction<_udRenderTarget_Destroy_dart>();

// udRenderTarget_SetTargets
// C declaration: udError udRenderTarget_SetTargets(struct udRenderTarget *pRenderTarget, void *pColorBuffer, uint32_t colorClearValue, void *pDepthBuffer);
// TODO maybe change the Point<Void> to IntPtr ??
typedef _udRenderTarget_SetTargets_native = Int32 Function(
    IntPtr, Pointer, Uint32, Pointer);
typedef _udRenderTarget_SetTargets_dart = int Function(
    int, Pointer, int, Pointer);
final _udRenderTarget_SetTargetsPointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_SetTargets_native>>(
        'udRenderTarget_SetTargets');
final _udRenderTarget_SetTargets = _udRenderTarget_SetTargetsPointer
    .asFunction<_udRenderTarget_SetTargets_dart>();

// udRenderTarget_SetTargetsWithPitch
// C declaration: udError udRenderTarget_SetTargetsWithPitch(struct udRenderTarget *pRenderTarget, void *pColorBuffer, uint32_t colorClearValue, void *pDepthBuffer, uint32_t colorPitchInBytes, uint32_t depthPitchInBytes);
// TODO maybe change the Point<Void> to IntPtr ??
typedef _udRenderTarget_SetTargetsWithPitch_native = Int32 Function(
    IntPtr, Pointer<Void>, Uint32, Pointer<Void>, Uint32, Uint32);
typedef _udRenderTarget_SetTargetsWithPitch_dart = int Function(
    int, Pointer<Void>, int, Pointer<Void>, int, int);
final _udRenderTarget_SetTargetsWithPitchPointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_SetTargetsWithPitch_native>>(
        'udRenderTarget_SetTargetsWithPitch');
final _udRenderTarget_SetTargetsWithPitch =
    _udRenderTarget_SetTargetsWithPitchPointer
        .asFunction<_udRenderTarget_SetTargetsWithPitch_dart>();

// udRenderTarget_GetMatrix
// C declaration: udError udRenderTarget_GetMatrix(const struct udRenderTarget *pRenderTarget, enum udRenderTargetMatrix matrixType, double cameraMatrix[16]);
typedef _udRenderTarget_GetMatrix_native = Int32 Function(
    IntPtr, Int32, Pointer<Double>);
typedef _udRenderTarget_GetMatrix_dart = int Function(
    int, int, Pointer<Double>);
final _udRenderTarget_GetMatrixPointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_GetMatrix_native>>(
        'udRenderTarget_GetMatrix');
final _udRenderTarget_GetMatrix = _udRenderTarget_GetMatrixPointer
    .asFunction<_udRenderTarget_GetMatrix_dart>();

// udRenderTarget_SetMatrix
// C declaration: udError udRenderTarget_SetMatrix(struct udRenderTarget *pRenderTarget, enum udRenderTargetMatrix matrixType, const double cameraMatrix[16]);
typedef _udRenderTarget_SetMatrix_native = Int32 Function(
    IntPtr, Int32, Pointer<Double>);
typedef _udRenderTarget_SetMatrix_dart = int Function(
    int, int, Pointer<Double>);
final _udRenderTarget_SetMatrixPointer =
    udSdkLib.lookup<NativeFunction<_udRenderTarget_SetMatrix_native>>(
        'udRenderTarget_SetMatrix');
final _udRenderTarget_SetMatrix = _udRenderTarget_SetMatrixPointer
    .asFunction<_udRenderTarget_SetMatrix_dart>();
