// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:Pointfluent/widgets/UdsModel.dart';

void main() {
  group('UdsModel', () {
    test('url', () {
      const location = "https://euclideon.test.com/DirCube.uds";
      final model = new UdsModel(
        type: ModelType.url,
        location: location,
      );

      expect(model.name, "DirCube");
      expect(model.location, location);
      expect(model.type, ModelType.url);
    });

    test('filePath', () {
      const location = "/data/data/src.com.file.example/files/Axis.UDS";
      final model = new UdsModel(
        type: ModelType.filePath,
        location: location,
      );

      expect(model.name, "Axis");
      expect(model.location, location);
      expect(model.type, ModelType.filePath);
    });

    test('bad file format', () {
      const location = "https://euclideon.test.com/DirCube.obj";
      expect(
        () => new UdsModel(
          type: ModelType.url,
          location: location,
        ),
        throwsFormatException,
      );
    });
  });
}
