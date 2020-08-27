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

  dynamic operator [](int index) {}

  void operator []=(int index, dynamic value) {}
}
