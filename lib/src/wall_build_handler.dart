import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/src/stone.dart';

/// Relative position of a stone in the Wall.
class StoneStartPosition {
  /// Wall column position.
  final int x;

  /// Wall row position.
  final int y;

  StoneStartPosition({required this.x, required this.y})
      : assert(x >= 0),
        assert(y >= 0);

  /// Computes the absolute brick position in a wall.
  /// [stoneSide] represents the smallest stone width/height.
  Offset operator *(double stoneSide) =>
      Offset(this.x * stoneSide, this.y * stoneSide);

  @override
  String toString() {
    return '$StoneStartPosition{x: $x, y: $y}';
  }
}

/// Define the wall width and height, where 1 unit refers to the side of a wall layer.
/// So all these values must be multiplied by the length of a side (in logical pixels),
/// if you want to have to logical pixels dimension.
class WallSize {
  /// Wall relative width
  final int width;

  /// Wall relative height
  final int height;

  const WallSize(this.width, this.height)
      : assert(width > 0),
        assert(height > 0);

  /// Flip width with Height, and returns a new instance
  get flipped => WallSize(this.height, this.width);

  /// Compute surface area of the wall size
  get surface => this.height * this.width;

  /// Let's you multiply the wall size by a logical pixels width,
  /// to have the logical pixels dimensions of the wall.
  Size operator *(double stoneSide) =>
      Size(width.toDouble() * stoneSide, height.toDouble() * stoneSide);

  @override
  int get hashCode => hashList([width, height]);

  @override
  bool operator ==(Object other) {
    if (other is WallSize) {
      return this.width == other.width && this.height == other.height;
    }
    return super == other;
  }

  @override
  String toString() {
    return "$WallSize(width:$width, height:$height)";
  }
}

class WallBlueprint {
  final Map<Stone, StoneStartPosition> stonesPosition;
  final WallSize size;

  WallBlueprint({required this.stonesPosition, required this.size});
}

abstract class WallBuildHandler {
  /// Define how many layers of the main axis the wall possess.
  late int _mainAxisSeparations;

  /// Define how many layers of the main axis the wall possess.
  int get mainAxisSeparations => _mainAxisSeparations;

  /// Define wall build direction, like [ListView].direction input parameter.
  late Axis _direction;

  /// Define wall build direction, like [ListView].direction input parameter.
  Axis get direction => _direction;

  /// Define whether the wall must be displayed in reverse, like [ListView].reverse input parameter.
  late bool _reverse;

  /// Define whether the wall must be displayed in reverse, like [ListView].reverse input parameter.
  bool get reverse => _reverse;

  WallBuildHandler();

  /// Must be executed before accessing to wall size property and getPosition method.
  WallBlueprint build(
      {required int mainAxisSeparations,
      required bool reverse,
      required Axis direction,
      required List<Stone> stones}) {
    this._direction = direction;
    this._reverse = reverse;
    this._mainAxisSeparations = mainAxisSeparations;
    final positions = computeStonePositions(stones);
    assertNoOverlap(positions);
    assertNoDrawOutside(positions);
    final wallSize = computeSize(positions);
    return WallBlueprint(stonesPosition: positions, size: wallSize);
  }

  /// Let you compute stone position for each stones.
  Map<Stone, StoneStartPosition> computeStonePositions(List<Stone> stones);

  /// Compute the wall size from the stones positions.
  @visibleForTesting
  WallSize computeSize(Map<Stone, StoneStartPosition> stonesPositions) {
    final posBottomRight = stonesPositions.map((key, value) => MapEntry(key,
        StoneStartPosition(x: value.x + key.width, y: value.y + key.height)));
    int maxX = 0, maxY = 0;
    posBottomRight.forEach((stone, pos) {
      maxX = max(maxX, pos.x);
      maxY = max(maxY, pos.y);
    });
    return WallSize(maxX, maxY);
  }

  @visibleForTesting
  void assertNoOverlap(Map<Stone, StoneStartPosition> stonesPositions) {
    final bounds = stonesPositions.map((key, value) => MapEntry(
        key,
        Rect.fromLTWH(value.x.toDouble(), value.y.toDouble(),
            key.width.toDouble(), key.height.toDouble())));
    bool overlap = false;
    bounds.forEach((key, value) {
      bounds.forEach((key2, value2) {
        if (key != key2 && value.overlaps(value2)) {
          overlap = true;
          print("Overlapping stones: $key $key2");
        }
      });
    });
    assert(!overlap,
        "Two stones or more are overlapping (check console for more details)!");
  }

  @visibleForTesting
  void assertNoDrawOutside(Map<Stone, StoneStartPosition> stonesPositions) {
    final stonesOutside = stonesPositions.map((key, value) {
      bool isOutside = false;
      if (this.direction == Axis.vertical) {
        isOutside = (value.x + key.width) > mainAxisSeparations;
      } else {
        isOutside = (value.y + key.height) > mainAxisSeparations;
      }
      return MapEntry(key, isOutside);
    });
    stonesOutside.removeWhere((key, value) => value == false);
    stonesOutside.forEach((key, _) {
      print(
          "Error: stone $key will be drawn outside wall with position ${stonesPositions[key]}");
    });
    assert(stonesOutside.isEmpty,
        "Stones must not draw outside the wall (see logs for more details)");
  }
}

/// Class determining how the wall will be built.
/// It main goals are to compute wall height and position every stones into the wall.
class DefaultWallBuildHandler extends WallBuildHandler {
  /// Internal attribute storing stones positions as a 2D Table.
  @visibleForTesting
  late List<int?> grid;
  int _gridLastIndex = 0;

  DefaultWallBuildHandler() : super();

  /// Compute stones position and wall size.
  /// Must be executed before accessing to wall size property and getPosition method.
  @override
  Map<Stone, StoneStartPosition> computeStonePositions(List<Stone> stones) {
    // instantiate grid
    final surface = stones.fold<int>(0, (sum, cell) => sum + cell.surface);
    grid = List<int?>.generate(surface * mainAxisSeparations, (index) => null);

    // set stones positions in grid
    stones.forEach((stone) => computeStonePosition(stone));

    //remove unwanted grid data
    int startRemove = _gridLastIndex + 1;
    int diff = startRemove % mainAxisSeparations;
    if (diff > 0) {
      startRemove += mainAxisSeparations - diff;
    }
    grid.removeRange(startRemove, grid.length);

    //reverse grid if we are in reverse display mode
    if (reverse) {
      grid = grid.reversed.toList();
    }

    return stones
        .asMap()
        .map((key, value) => MapEntry(value, _getPosition(value)));
  }

  bool __canFit(Stone stone, int firstIndex) {
    final placeLeft =
        this.mainAxisSeparations - (firstIndex % this.mainAxisSeparations);
    if ((this.direction == Axis.vertical ? stone.width : stone.height) >
        placeLeft) {
      return false;
    }

    bool found = true;
    for (var j = 0; j < stone.width; j++) {
      for (var k = 0; k < stone.height; k++) {
        found &= grid[firstIndex + __getGridPos(j, k)] == null;
      }
    }
    return found;
  }

  int __getGridPos(int column, int row) {
    if (this.direction == Axis.vertical) {
      return column + mainAxisSeparations * row;
    } else {
      return row + mainAxisSeparations * column;
    }
  }

  void __placeOnGrid(Stone brick, int firstIndex) {
    int pos = 0;
    for (var j = 0; j < brick.width; j++) {
      for (var k = 0; k < brick.height; k++) {
        pos = firstIndex + __getGridPos(j, k);
        grid[pos] = brick.id as int;
        _gridLastIndex = max(_gridLastIndex, pos);
      }
    }
  }

  /// Compute the position of the stone, and set it on the grid.
  @visibleForTesting
  void computeStonePosition(Stone stone) {
    // find first place in grid that accept brick's surface
    bool found = false;
    int startSearchPlace = 0;
    int? availablePlace;

    while (!found) {
      availablePlace =
          grid.indexWhere((element) => element == null, startSearchPlace);
      found = __canFit(stone, availablePlace);
      startSearchPlace = availablePlace + 1;
    }
    __placeOnGrid(stone, availablePlace!);
  }

  /// Returns the position of a specific stone.
  /// Throw an error if [compute] method hasn't been called before.
  StoneStartPosition _getPosition(Stone stone) {
    int start = this.grid.indexOf(stone.id as int);
    int x, y;
    if (this.direction == Axis.vertical) {
      x = start % mainAxisSeparations;
      y = start ~/ mainAxisSeparations;
    } else {
      x = start ~/ mainAxisSeparations;
      y = start % mainAxisSeparations;
    }
    return StoneStartPosition(x: x, y: y);
  }

  @override
  String toString() {
    final stringBuffer = StringBuffer("$DefaultWallBuildHandler\n");
    if (this.direction == Axis.vertical) {
      for (int i = 0; i < grid.length; i += mainAxisSeparations) {
        stringBuffer
            .writeln(grid.sublist(i, i + mainAxisSeparations).join(" | "));
      }
    } else {
      List<List<int>> rows =
          List<List<int>>.generate(mainAxisSeparations, (index) => []);
      for (int i = 0; i < grid.length; i++) {
        rows[i % mainAxisSeparations].add(grid[i]!);
      }
      rows.forEach((row) => stringBuffer.writeln(row.join(" | ")));
    }
    return stringBuffer.toString();
  }
}
