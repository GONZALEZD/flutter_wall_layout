import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/src/stone.dart';

import '../wall_builder.dart';

/// Class determining how the wall will be built.
/// It main goals are to compute wall height and position every stones into the wall.
class DefaultWallBuildHandler extends WallBuilder {
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
