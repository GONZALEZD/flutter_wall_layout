import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wall_layout/flutter_wall_layout.dart';

import 'package:flutter_wall_layout/src/wall_layout.dart';

void main() {
  late List<Stone> stones;
  setUp(() {
    stones = [
      Stone(
        id: 1,
        child: Container(),
        width: 2,
        height: 2,
      ),
      Stone(
        id: 2,
        child: Container(),
        width: 2,
        height: 1,
      ),
      Stone(
        id: 3,
        child: Container(),
        width: 1,
        height: 2,
      ),
      Stone(
        id: 4,
        child: Container(),
        width: 1,
        height: 1,
      ),
      Stone(
        id: 5,
        child: Container(),
        width: 3,
        height: 2,
      ),
      Stone(
        id: 6,
        child: Container(),
        width: 1,
        height: 1,
      ),
      Stone(
        id: 7,
        child: Container(),
        width: 2,
        height: 3,
      ),
    ];
  });
  group("$WallLayout Class", () {
    test("Initialization", () {
      expect(
          () => WallLayout(
                stones: [],
                layersCount: 2,
              ),
          throwsAssertionError,
          reason: "$WallLayout must throw error if stones list is empty");
      expect(
          () => WallLayout(
                stones: stones,
                layersCount: 1,
              ),
          throwsAssertionError,
          reason:
              "$WallLayout must throw error if stones divisions is lower than 2 (axis division equal to 1 is equivalent to a ListView, so no interest)");
      expect(
          () => WallLayout(
                stones: stones,
                layersCount: 2,
                scrollDirection: Axis.vertical,
              ),
          throwsAssertionError,
          reason:
              "$WallLayout must throw error if at least one stone width is bigger than allowed divisions (in vertical Axis).");
      expect(
          () => WallLayout(
                stones: stones,
                layersCount: 2,
                scrollDirection: Axis.horizontal,
              ),
          throwsAssertionError,
          reason:
              "$WallLayout must throw error if at least one stone height is bigger than allowed divisions (in horizontal Axis).");

      expect(
          () => WallLayout(
              stones: stones +
                  [
                    Stone(
                      id: 1,
                      child: Container(),
                      width: 2,
                      height: 3,
                    )
                  ],
              layersCount: 4),
          throwsAssertionError,
          reason:
              "$WallLayout must throw error if two stones have the same id.");
    });
  });
}
