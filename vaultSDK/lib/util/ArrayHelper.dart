import 'dart:ffi';
import 'package:ffi/ffi.dart';

abstract class ArrayHelper {
  final struct;
  final List<int> dimensions;
  final int level;
  final int absoluteIndex;
  int get length => dimensions[level];
  ArrayHelper(this.struct, this.dimensions, this.level, this.absoluteIndex);

  void checkBounds(int index) {
    if (index >= length || index < 0) {
      throw RangeError(
          'Dimension $level: index not in range 0..${length} exclusive.');
    }
  }

  List get values {
    List newList = new List();
    for (int i = 0; i < this.length; i++) {
      newList.add(this[i]);
    }
    return newList;
  }

  set values(List list) {
    for (int i = 0; i < this.length; i++) {
      this[i] = list[i];
    }
  }

  dynamic operator [](int index) {}

  void operator []=(int index, dynamic value) {}
}

/// Allocates a Pointer<Double> and copies in the contents of a dart List
Pointer<Double> doubleListToCArray(List<double> list) {
  Pointer<Double> cArray = allocate(count: list.length);
  cArray.asTypedList(list.length).setAll(0, list);
  return cArray;
}
