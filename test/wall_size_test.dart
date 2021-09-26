import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wall_layout/wall_builder.dart';

void main() {
  group("$WallSize Class", () {
    test("Initialization", () {
      expect(() => WallSize(-2, 2), throwsAssertionError,
          reason: "$WallSize must throw error is width is lower than 1.");
      expect(() => WallSize(2, -4), throwsAssertionError,
          reason: "$WallSize must throw error is height is lower than 1.");
    });
    test("Surface", () {
      expect(WallSize(2, 3).surface, 6,
          reason: "Incorrect surface computation");
      expect(WallSize(1, 23).surface, 23,
          reason: "Incorrect surface computation");
      expect(WallSize(12, 2).surface, 24,
          reason: "Incorrect surface computation");
    });
    test("* operator", () {
      expect(WallSize(6, 2) * 2.0, Size(12.0, 4.0),
          reason: "Incorrect multiplication");
      expect(WallSize(1, 3) * -3.0, Size(-3.0, -9.0),
          reason: "Incorrect multiplication");
    });
    test("Flipped $WallSize", () {
      expect(WallSize(2, 3).flipped, WallSize(3, 2),
          reason: "Flipped height and width not working");
    });
  });
}
