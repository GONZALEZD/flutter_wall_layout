import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_wall_layout/flutter_wall_layout.dart';

void main() {
  group("$Stone Class", () {
    test("Initialization", () {
      expect(() => Stone(width: 2, height: 2, child: Container()), throwsAssertionError, reason: "Stone missing ID must throw error");
      expect(() => Stone(id: 1, width: 2, height: 2), throwsAssertionError, reason: "Stone missing child widget must throw error");
      expect(() => Stone(id: 1, height: 2,child: Container()), throwsAssertionError, reason: "Stone missing height must throw error");
      expect(() => Stone(id: 1, width: 2, child: Container()), throwsAssertionError, reason: "Stone missing width must throw error");

      expect(() => Stone(id: 1, width: 0, height: 2, child: Container()), throwsAssertionError, reason: "Stone must check that width is higher than 0");
      expect(() => Stone(id: 1, width: 2, height: 0, child: Container()), throwsAssertionError, reason: "Stone must check that height is higher than 0");
    });
    test("Surface", () {
      expect(Stone(id:1, width: 2, height: 2, child: Container()).surface, 4, reason: "Incorrect stone surface");
      expect(Stone(id:1, width: 1, height: 20, child: Container()).surface, 20, reason: "Incorrect stone surface");
      expect(Stone(id:1, width: 6, height: 3, child: Container()).surface, 18, reason: "Incorrect stone surface");
      expect(Stone(id:1, width: 1, height: 1, child: Container()).surface, 1, reason: "Incorrect stone surface");
    });
  });
}
