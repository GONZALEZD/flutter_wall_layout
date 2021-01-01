import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wall_layout/layout/stone.dart';

import 'package:flutter_wall_layout/layout/wall_build_handler.dart';

void main() {
  group("$WallBuildHandler Class", () {
    List<Stone> stones;
    setUp(() {
      stones = [
        Stone(id: 1, child: Container(), width: 2, height: 1,),
        Stone(id: 2, child: Container(), width: 2, height: 2,),
        Stone(id: 3, child: Container(), width: 1, height: 1,),
        Stone(id: 4, child: Container(), width: 1, height: 1,),
      ];
    });
    test("Instantiation", () {
      expect(()=> WallBuildHandler(axisSeparations: 2), throwsAssertionError, reason: "$WallBuildHandler must throw error if stones list is not defined");
      expect(()=> WallBuildHandler(stones: stones), throwsAssertionError, reason: "$WallBuildHandler must throw error if axis separations is not defined");
    });
    test("Vertical list", () {
      final handler = WallBuildHandler(stones: stones, axisSeparations: 2);
      expect(() => handler.size, throwsAssertionError, reason: "$WallBuildHandler must throw error if you access to size property without having called setup");
      handler.setup();
      expect(handler.size, WallSize(2, 4), reason: "Computed wall size is incorrect");
      expect(handler.grid, [1,1,2,2,2,2,3,4], reason: "Computed grid is incorrect");
    });
    test("Reverse vertical list", () {
      final handler = WallBuildHandler(stones: stones, axisSeparations: 3, reverse: true);
      handler.setup();
      expect(handler.size, WallSize(3, 3), reason: "Computed wall size is incorrect");
      expect(handler.grid, [null, 2, 2, 4, 2, 2, 3, 1, 1], reason: "Computed grid is incorrect");
    });
    test("Horizontal list", () {
      final handler = WallBuildHandler(stones: stones, axisSeparations: 2, direction: Axis.horizontal);
      handler.setup();
      expect(handler.size, WallSize(4, 2), reason: "Computed wall size is incorrect");
      expect(handler.grid, [1,3,1,4,2,2,2,2], reason: "Computed grid is incorrect");
    });
    test("Reverse horizontal list", () {
      final handler = WallBuildHandler(stones: stones, axisSeparations: 3, direction: Axis.horizontal, reverse: true);
      handler.setup();
      expect(handler.size, WallSize(3, 3), reason: "Computed wall size is incorrect");
      expect(handler.grid, [null, 4, 3, 2, 2, 1, 2, 2, 1], reason: "Computed grid is incorrect");
    });
  });
}
