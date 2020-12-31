import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/stone.dart';

/// Relative position of a stone in the Wall.
class StonePosition {
  /// Wall column position.
  final int x;
  /// Wall row position.
  final int y;

  StonePosition({this.x, this.y});

  /// Computes the absolute brick position in a wall.
  /// [stoneSide] represents the smallest stone width/height.
  Offset operator *(double stoneSide) => Offset(this.x * stoneSide, this.y * stoneSide);
}

class WallSize {
  final int width;
  final int height;

  WallSize(this.width, this.height);

  get flipped => WallSize(this.height, this.width);

  get surface => this.height*this.width;
}

/// Class determining how the wall will be built.
/// It main goals are to compute wall height and position every stones into the wall.
class WallBuildHandler {
  /// Define how many columns the wall possess.
  final int axisSeparations;

  final bool reverse;

  final Axis direction;

  final List<Stone> stones;

  List<int> _grid;
  WallSize _wallSize;

  WallBuildHandler(
      {this.axisSeparations, this.reverse = false, this.direction = Axis.vertical, this.stones}) {
    _grid = [];
    _wallSize = null;
  }

  void setup() {
    // instantiate grid
    final surface = this.stones.fold(0, (sum, cell) => sum + cell.surface);
    _grid = List<int>.generate(surface * axisSeparations, (index) => null);

    // set stones positions in grid
    this.stones.forEach((stone) => _computeStonePosition(stone));

    //compute grid height and width
    _wallSize = _computeSize();

    //remove unwanted grid data
    _grid.removeRange(_wallSize.surface, _grid.length);

    //reverse grid if we are in reverse display mode
    if(this.reverse) {
      _grid = _grid.reversed.toList();
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
        found &= _grid[firstIndex + __getGridPos(j, k)] == null;
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
        _grid[firstIndex + __getGridPos(j, k)] = brick.id;
      }
    }
  }

  void _computeStonePosition(Stone stone) {
    // find first place in grid that accept brick's surface
    bool found = false;
    int startSearchPlace = 0;
    int availablePlace;

    while (!found) {
      availablePlace = _grid.indexWhere((element) => element == null, startSearchPlace);
      found = __canFit(stone, availablePlace);
      startSearchPlace = availablePlace + 1;
    }
    __placeOnGrid(stone, availablePlace);
  }

  WallSize _computeSize() {
    final lastIndex = _grid.lastIndexWhere((element) => element != null);
    final largeSide = (lastIndex ~/ axisSeparations) + 1;
    WallSize size = WallSize(this.axisSeparations, largeSide);
    if (this.direction == Axis.horizontal) {
      size = size.flipped;
    }
    return size;
  }

  int get height {
    assert(_wallSize != null, "Must call setup first");
    return _wallSize.height;
  }

  int get width {
    assert(_wallSize != null, "Must call setup first");
    return _wallSize.width;
  }

  StonePosition getPosition(Stone stone) {
    int start = this._grid.indexOf(stone.id);
    int x, y;
    if(this.direction == Axis.vertical) {
      x = start % axisSeparations;
      y = start ~/ axisSeparations;
    }
    else {
      x = start ~/ axisSeparations;
      y = start % axisSeparations;

    }
    return StonePosition(x: x, y: y);
  }

  @override
  String toString() {
    final stringBuffer = StringBuffer("$WallBuildHandler\n");
    if (this.direction == Axis.vertical) {
      for (int i = 0; i < _grid.length; i += axisSeparations) {
        stringBuffer.writeln(_grid.sublist(i, i + axisSeparations).join(" | "));
      }
    } else {
      List<List<int>> rows = List<List<int>>.generate(axisSeparations, (index) => List<int>());
      for (int i = 0; i < _grid.length; i++) {
        rows[i % axisSeparations].add(_grid[i]);
      }
      rows.forEach((row) => stringBuffer.writeln(row.join(" | ")));
    }
    return stringBuffer.toString();
  }
}