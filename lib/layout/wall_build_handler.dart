import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/layout/stone.dart';

/// Relative position of a stone in the Wall.
class StonePosition {
  /// Wall column position.
  final int x;

  /// Wall row position.
  final int y;

  StonePosition({this.x, this.y})
      : assert(x != null && x >= 0),
        assert(y != null && y >= 0);

  /// Computes the absolute brick position in a wall.
  /// [stoneSide] represents the smallest stone width/height.
  Offset operator *(double stoneSide) => Offset(this.x * stoneSide, this.y * stoneSide);
}

class WallSize {
  final int width;
  final int height;

  WallSize(this.width, this.height)
      : assert(width != null && width > 0),
        assert(height != null && height > 0);

  get flipped => WallSize(this.height, this.width);

  get surface => this.height * this.width;

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

/// Class determining how the wall will be built.
/// It main goals are to compute wall height and position every stones into the wall.
class WallBuildHandler {
  /// Define how many columns the wall possess.
  final int axisSeparations;

  final bool reverse;

  final Axis direction;

  final List<Stone> stones;

  List<int> grid;
  WallSize _wallSize;

  WallBuildHandler(
      {this.axisSeparations, this.reverse = false, this.direction = Axis.vertical, this.stones})
      : assert(axisSeparations != null && axisSeparations >= 2),
        assert(direction != null),
        assert(stones != null && stones.isNotEmpty) {
    grid = [];
    _wallSize = null;
  }

  void setup() {
    // instantiate grid
    final surface = this.stones.fold(0, (sum, cell) => sum + cell.surface);
    grid = List<int>.generate(surface * axisSeparations, (index) => null);

    // set stones positions in grid
    this.stones.forEach((stone) => computeStonePosition(stone));

    //compute grid height and width
    _wallSize = computeSize();

    //remove unwanted grid data
    grid.removeRange(_wallSize.surface, grid.length);

    //reverse grid if we are in reverse display mode
    if (this.reverse) {
      grid = grid.reversed.toList();
    }
  }

  bool __canFit(Stone stone, int firstIndex) {
    final placeLeft = this.axisSeparations - (firstIndex % this.axisSeparations);
    if ((this.direction == Axis.vertical ? stone.width : stone.height) > placeLeft) {
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
      return column + axisSeparations * row;
    } else {
      return row + axisSeparations * column;
    }
  }

  void __placeOnGrid(Stone brick, int firstIndex) {
    for (var j = 0; j < brick.width; j++) {
      for (var k = 0; k < brick.height; k++) {
        grid[firstIndex + __getGridPos(j, k)] = brick.id;
      }
    }
  }

  void computeStonePosition(Stone stone) {
    // find first place in grid that accept brick's surface
    bool found = false;
    int startSearchPlace = 0;
    int availablePlace;

    while (!found) {
      availablePlace = grid.indexWhere((element) => element == null, startSearchPlace);
      found = __canFit(stone, availablePlace);
      startSearchPlace = availablePlace + 1;
    }
    __placeOnGrid(stone, availablePlace);
  }

  WallSize computeSize() {
    final lastIndex = grid.lastIndexWhere((element) => element != null);
    final largeSide = (lastIndex ~/ axisSeparations) + 1;
    WallSize size = WallSize(this.axisSeparations, largeSide);
    if (this.direction == Axis.horizontal) {
      size = size.flipped;
    }
    return size;
  }

  WallSize get size {
    assert(_wallSize != null, "Must call setup first");
    return _wallSize;
  }

  StonePosition getPosition(Stone stone) {
    int start = this.grid.indexOf(stone.id);
    int x, y;
    if (this.direction == Axis.vertical) {
      x = start % axisSeparations;
      y = start ~/ axisSeparations;
    } else {
      x = start ~/ axisSeparations;
      y = start % axisSeparations;
    }
    return StonePosition(x: x, y: y);
  }

  @override
  String toString() {
    final stringBuffer = StringBuffer("$WallBuildHandler\n");
    if (this.direction == Axis.vertical) {
      for (int i = 0; i < grid.length; i += axisSeparations) {
        stringBuffer.writeln(grid.sublist(i, i + axisSeparations).join(" | "));
      }
    } else {
      List<List<int>> rows = List<List<int>>.generate(axisSeparations, (index) => List<int>());
      for (int i = 0; i < grid.length; i++) {
        rows[i % axisSeparations].add(grid[i]);
      }
      rows.forEach((row) => stringBuffer.writeln(row.join(" | ")));
    }
    return stringBuffer.toString();
  }
}
