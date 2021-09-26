import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wall_layout/wall_builder.dart';

void main() {
  group("$StoneStartPosition Class", () {
    test("Initialisation", () {
      expect(() => StoneStartPosition(x: -1, y: 1), throwsAssertionError,
          reason: "Stone must throw error if X is lower than 1.");
      expect(() => StoneStartPosition(x: 3, y: -1), throwsAssertionError,
          reason: "Stone must throw error if Y is lower than 1.");
    });

    test("* operator", () {
      expect(StoneStartPosition(x: 2, y: 10) * 12.0, Offset(24.0, 120.0),
          reason: "Incorrect multiplication.");
      expect(StoneStartPosition(x: 3, y: 1) * -6.0, Offset(-18.0, -6.0),
          reason: "Incorrect multiplication.");
    });
  });
}
