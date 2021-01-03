import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wall_layout/layout/wall_build_handler.dart';

void main() {
  group("$StonePosition Class", () {
    test("Initialisation", () {
      expect(() => StonePosition(), throwsAssertionError, reason: "Stone must throw error if X and Y not defined.");
      expect(() => StonePosition(y: 2), throwsAssertionError, reason: "Stone must throw error if X is not defined.");
      expect(() => StonePosition(x: 3), throwsAssertionError, reason: "Stone must throw error if Y is not defined.");
      expect(() => StonePosition(x: -1, y: 1), throwsAssertionError, reason: "Stone must throw error if X is lower than 1.");
      expect(() => StonePosition(x: 3, y: -1), throwsAssertionError, reason: "Stone must throw error if Y is lower than 1.");
    });

    test("* operator", () {
      expect(StonePosition(x:2, y:10) * 12.0, Offset(24.0, 120.0), reason: "Incorrect multiplication.");
      expect(StonePosition(x:3, y:1) * -6.0, Offset(-18.0, -6.0), reason: "Incorrect multiplication.");
    });
  });
}