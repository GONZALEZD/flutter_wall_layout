import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/brick.dart';

/// Relative position of a brick in the Wall.
/// [x] refers to the wall column position.
/// [y] refers to the wall row position.
class BrickPosition {
  final int x;
  final int y;

  BrickPosition({this.x, this.y});

  /// Computes the absolute brick position in a wall.
  /// [brickSide] represents the smallest brick width/height.
  Offset operator *(double brickSide) => Offset(this.x * brickSide, this.y * brickSide);
}

class WallSize {
  final int width;
  final int height;

  WallSize(this.width, this.height);

  get flipped => WallSize(this.height, this.width);

  get surface => this.height*this.width;
}

/// Class determining how the wall will be built.
/// It main goals are to compute wall height and position every bricks into the wall.
class WallBuildHandler {
  /// Define how many columns the wall possess.
  final int axisSeparations;

  final bool reverse;

  final Axis direction;

  final List<Brick> bricks;

  List<int> _grid;
  WallSize _wallSize;

  WallBuildHandler(
      {this.axisSeparations, this.reverse = false, this.direction = Axis.vertical, this.bricks}) {
    _grid = [];
    _wallSize = null;
  }

  void setup() {
    var bricksList = this.bricks;

    // instantiate grid
    final surface = bricksList.fold(0, (sum, cell) => sum + cell.surface);
    _grid = List<int>.generate(surface * axisSeparations, (index) => null);

    // set bricks positions in grid
    bricksList.forEach((brick) => _setBrickPosition(brick));

    //compute grid height and width
    _wallSize = _computeSize();

    //remove unwanted grid data
    _grid.removeRange(_wallSize.surface, _grid.length);

    //reverse grid if we are in reverse display mode
    if(this.reverse) {
      _grid = _grid.reversed.toList();
    }
  }

  bool __canFit(Brick brick, int firstIndex) {
    final placeLeft = this.axisSeparations - (firstIndex % this.axisSeparations);
    if ((this.direction == Axis.vertical ? brick.width : brick.height) > placeLeft) {
      return false;
    }

    bool found = true;
    for (var j = 0; j < brick.width; j++) {
      for (var k = 0; k < brick.height; k++) {
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

  void __placeOnGrid(Brick brick, int firstIndex) {
    for (var j = 0; j < brick.width; j++) {
      for (var k = 0; k < brick.height; k++) {
        _grid[firstIndex + __getGridPos(j, k)] = brick.id;
      }
    }
  }

  void _setBrickPosition(Brick brick) {
    // find first place in grid that accept brick's surface
    bool found = false;
    int startSearchPlace = 0;
    int availablePlace;

    while (!found) {
      availablePlace = _grid.indexWhere((element) => element == null, startSearchPlace);
      found = __canFit(brick, availablePlace);
      startSearchPlace = availablePlace + 1;
    }
    __placeOnGrid(brick, availablePlace);
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

  BrickPosition getPosition(Brick brick) {
    int start = this._grid.indexOf(brick.id);
    int x, y;
    if(this.direction == Axis.vertical) {
      x = start % axisSeparations;
      y = start ~/ axisSeparations;
    }
    else {
      x = start ~/ axisSeparations;
      y = start % axisSeparations;

    }
    return BrickPosition(x: x, y: y);
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