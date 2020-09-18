import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

// import 'package:path_provider/path_provider.dart';

import 'package:vaultSDK/udContext.dart';
import 'package:vaultSDK/udRenderContext.dart';
import 'package:vaultSDK/udRenderTarget.dart';
import 'package:vaultSDK/udPointCloud.dart';
import 'package:vaultSDK/udConfig.dart';

const List<double> cameraMatrix = [
  1, 0, 0, 0, //
  0, 1, 0, 0, //
  0, 0, 1, 0, //
  5, -75, 5, 1 //
];

Future<File> writeBitmap(List<int> bytes) async {
  // final directory = await getExternalStorageDirectory();
  // final path = directory.path;
  const path = "/storage/emulated/0/Android/data/com.example.Pointfluent/files";
  final file = File('$path/render.bmp');

  // Write the file.
  return file.writeAsBytes(bytes);
}

class BMP332Header {
  int _width; // NOTE: width must be multiple of 4 as no account is made for bitmap padding
  int _height;

  Uint8List _bmp;
  int _totalHeaderSize;

  BMP332Header(this._width, this._height) : assert(_width & 3 == 0) {
    int baseHeaderSize = 54;
    _totalHeaderSize = baseHeaderSize + 1024; // base + color map
    int fileLength = _totalHeaderSize + _width * _height; // header + bitmap
    _bmp = new Uint8List(fileLength);
    ByteData bd = _bmp.buffer.asByteData();
    bd.setUint8(0, 0x42);
    bd.setUint8(1, 0x4d);
    bd.setUint32(2, fileLength, Endian.little); // file length
    bd.setUint32(10, _totalHeaderSize, Endian.little); // start of the bitmap
    bd.setUint32(14, 40, Endian.little); // info header size
    bd.setUint32(18, _width, Endian.little);
    bd.setUint32(22, _height, Endian.little);
    bd.setUint16(26, 1, Endian.little); // planes
    bd.setUint32(28, 8, Endian.little); // bpp
    bd.setUint32(30, 0, Endian.little); // compression
    bd.setUint32(34, _width * _height, Endian.little); // bitmap size
    // leave everything else as zero

    // there are 256 possible variations of pixel
    // build the indexed color map that maps from packed byte to RGBA32
    // better still, create a lookup table see: http://unwind.se/bgr233/
    for (int rgb = 0; rgb < 256; rgb++) {
      int offset = baseHeaderSize + rgb * 4;

      int red = rgb & 0xe0;
      int green = rgb << 3 & 0xe0;
      int blue = rgb & 6 & 0xc0;

      bd.setUint8(offset + 3, 255); // A
      bd.setUint8(offset + 2, red); // R
      bd.setUint8(offset + 1, green); // G
      bd.setUint8(offset, blue); // B
    }
  }

  /// Insert the provided bitmap after the header and return the whole BMP
  Uint8List appendBitmap(Uint8List bitmap) {
    int size = _width * _height;
    assert(bitmap.length == size);
    _bmp.setRange(_totalHeaderSize, _totalHeaderSize + size, bitmap);
    return _bmp;
  }
}

void main() {
  final width = 640;
  final height = 480;
  final username = ""; // INSERT
  final password = ""; // INSERT
  final modelName = "https://models.euclideon.com/DirCube.uds";

  final udContext = UdContext();
  final renderContext = UdRenderContext();
  final renderTarget = UdRenderTarget(width, height);
  final pointCloud = UdPointCloud();

  UdConfig.ignoreCertificateVerification(true);
  udContext.connect(username, password);

  renderContext.create(udContext);

  renderTarget.create(udContext, renderContext);

  pointCloud.load(udContext, modelName);
  renderContext.setRenderInstancePointCloud(pointCloud);

  renderContext.renderInstance.setMatrix(cameraMatrix);

  renderTarget.setTargets();

  renderTarget.setMatrix(udRenderTargetMatrix.udRTM_Camera, cameraMatrix);
  renderContext.renderSettings.flags =
      udRenderContextFlags.udRCF_BlockingStreaming;

  renderContext.render(renderTarget, modelCount: 1);

  // add a windows BMP header to the bytes
  Uint8List colorBuffer = Uint8List.fromList(renderTarget.colorBuffer);
  Uint8List bmp;
  BMP332Header header = BMP332Header(width, height);
  bmp = header.appendBitmap(colorBuffer);

  writeBitmap(bmp);

  // Cleanup
  pointCloud.unLoad();
  renderTarget.destroy();
  renderContext.destroy();
  udContext.disconnect();

  log("Exit 0");
}
