class Result {
  int value;
  String message;

  Result({this.value, this.message});

  bool get error {
    if (value == null) return false;
    return value > 0;
  }

  bool get ok {
    if (value == null) return false;
    return value == 0;
  }
}
