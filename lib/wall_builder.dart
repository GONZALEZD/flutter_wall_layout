import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/src/default_wall_builder.dart';
import 'package:flutter_wall_layout/src/stone.dart';

/// Relative start position of a stone in the Wall.
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

/// Define the blueprint of the wall.
/// It contains (relative) location of all stones,
/// and the overall size of the wall.
class WallBlueprint {
  final Map<Stone, StoneStartPosition> stonesPosition;
  final WallSize size;

  WallBlueprint({required this.stonesPosition, required this.size});
}

/// Defines how the wall will be built
/// If you want to define your own algorithm,
/// you will have to inherit from this abstract class,
/// and implements the method [WallBuilder.computeStonePositions].
abstract class WallBuilder {
  /// Default [WallBuilder] implementation
  factory WallBuilder.standard() => DefaultWallBuildHandler();

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

  /// Default constructor.
  WallBuilder();

  /// Build the wall with scrollview parameters
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

  /// Let you compute stone position for each stone.
  /// StonePositions must not overlap (stack not allowed),
  /// and not been drawn outside the wall
  /// (depending on [WallBuilder.mainAxisSeparations]).
  ///
  /// To help you, the [WallBuilder] will check these two requisites.
  /// Added to that, you have access to layout main data:
  /// - [WallBuilder.direction] : Direction of the wall to draw
  /// - [WallBuilder.mainAxisSeparations] : number of elements of the main direction.
  /// - [WallBuilder.reverse] : define whether to display the stones in reverse mode (check [ScrollView.reverse])
  /// The returned data will be used to draw stones.
  /// If a stone is not in this map, it won't be drawn.
  /// All new created Stone inserted in the Map will be taken into account.
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
          print(
              "Overlapping stones: $key (${stonesPositions[key]})\n $key2 (${stonesPositions[key2]})");
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
