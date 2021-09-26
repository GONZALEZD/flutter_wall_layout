import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_wall_layout/src/stone.dart';
import 'package:flutter_wall_layout/src/wall_build_handler.dart';

class WallBuildHandlerMock extends WallBuildHandler {
  final Map<Stone, StoneStartPosition> data;
  final WallSize size;

  late int mainAxisSeparations;
  late Axis direction;
  late bool reverse;

  WallBuildHandlerMock({required this.data, required this.size});

  @override
  Map<Stone, StoneStartPosition> computeStonePositions(List<Stone> stones) {
    return data;
  }

  @override
  WallBlueprint build(
      {required int mainAxisSeparations,
      required bool reverse,
      required Axis direction,
      required List<Stone> stones}) {
    this.mainAxisSeparations = mainAxisSeparations;
    this.direction = direction;
    this.reverse = reverse;
    return WallBlueprint(stonesPosition: data, size: size);
  }
}

void main() {
  group("$DefaultWallBuildHandler Class", () {
    late List<Stone> stones;
    setUp(() {
      stones = [
        Stone(
          id: 1,
          child: Container(),
          width: 2,
          height: 1,
        ),
        Stone(
          id: 2,
          child: Container(),
          width: 2,
          height: 2,
        ),
        Stone(
          id: 3,
          child: Container(),
          width: 1,
          height: 1,
        ),
        Stone(
          id: 4,
          child: Container(),
          width: 1,
          height: 1,
        ),
      ];
    });
    test("Vertical list", () {
      final handler = DefaultWallBuildHandler();
      final blueprint = handler.build(
          stones: stones,
          mainAxisSeparations: 2,
          direction: Axis.vertical,
          reverse: false);
      expect(blueprint.size, WallSize(2, 4),
          reason: "Computed wall size is incorrect");
      expect(handler.grid, [1, 1, 2, 2, 2, 2, 3, 4],
          reason: "Computed grid is incorrect");
    });
    test("Vertical list 2", () {
      final handler = DefaultWallBuildHandler();
      final blueprint = handler.build(
          stones: stones,
          mainAxisSeparations: 3,
          direction: Axis.vertical,
          reverse: false);
      expect(blueprint.size, WallSize(3, 3),
          reason: "Computed wall size is incorrect");
      expect(handler.grid, [1, 1, 3, 2, 2, 4, 2, 2, null],
          reason: "Computed grid is incorrect");
    });
    test("Reverse vertical list", () {
      final handler = DefaultWallBuildHandler();
      final blueprint = handler.build(
          stones: stones,
          mainAxisSeparations: 3,
          reverse: true,
          direction: Axis.vertical);
      expect(blueprint.size, WallSize(3, 3),
          reason: "Computed wall size is incorrect");
      expect(handler.grid, [null, 2, 2, 4, 2, 2, 3, 1, 1],
          reason: "Computed grid is incorrect");
    });
    test("Horizontal list", () {
      final handler = DefaultWallBuildHandler();
      final blueprint = handler.build(
          stones: stones,
          mainAxisSeparations: 2,
          direction: Axis.horizontal,
          reverse: false);
      expect(blueprint.size, WallSize(4, 2),
          reason: "Computed wall size is incorrect");
      expect(handler.grid, [1, 3, 1, 4, 2, 2, 2, 2],
          reason: "Computed grid is incorrect");
    });
    test("Reverse horizontal list", () {
      final handler = DefaultWallBuildHandler();
      final blueprint = handler.build(
          stones: stones,
          mainAxisSeparations: 3,
          direction: Axis.horizontal,
          reverse: true);
      expect(blueprint.size, WallSize(3, 3),
          reason: "Computed wall size is incorrect");
      expect(handler.grid, [null, 4, 3, 2, 2, 1, 2, 2, 1],
          reason: "Computed grid is incorrect");
    });
    test("Overlapping Stones check", () {
      final handler = WallBuildHandlerMock(data: {
        Stone(id: 1, child: Container(), width: 2, height: 2):
            StoneStartPosition(x: 0, y: 0),
        Stone(id: 2, child: Container(), width: 1, height: 1):
            StoneStartPosition(x: 2, y: 0),
        Stone(id: 3, child: Container(), width: 1, height: 1):
            StoneStartPosition(x: 2, y: 1),
        Stone(id: 4, child: Container(), width: 2, height: 2):
            StoneStartPosition(x: 1, y: 1),
      }, size: WallSize(1, 1));
      handler.build(
          mainAxisSeparations: 3,
          reverse: false,
          direction: Axis.vertical,
          stones: handler.data.keys.toList());
      expect(() => handler.assertNoOverlap(handler.data), throwsAssertionError);
    });
    test("Drawn outside stones check", () {
      final handler = WallBuildHandlerMock(data: {
        Stone(id: 1, child: Container(), width: 2, height: 2):
        StoneStartPosition(x: 0, y: 0),
        Stone(id: 2, child: Container(), width: 1, height: 1):
        StoneStartPosition(x: 2, y: 0),
        Stone(id: 3, child: Container(), width: 1, height: 1):
        StoneStartPosition(x: 2, y: 1),
        Stone(id: 4, child: Container(), width: 2, height: 2):
        StoneStartPosition(x: 2, y: 1),
      }, size: WallSize(1, 1));
      handler.build(
          mainAxisSeparations: 3,
          reverse: false,
          direction: Axis.vertical,
          stones: handler.data.keys.toList());
      expect(() => handler.assertNoDrawOutside(handler.data), throwsAssertionError);
    });
  });
}
