import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/src/stone.dart';
import 'package:flutter_wall_layout/src/wall_build_handler.dart';

class WallLayout extends StatefulWidget {
  static const double DEFAULT_BRICK_PADDING = 16.0;

  /// Define the number of layers the wall have. Must be higher or equal to 2.
  /// When direction is Axis.vertical, it defines the number of columns the wall has.
  /// When direction is Axis.horizontal, it defines the number of rows.
  final int layersCount;

  /// List of Stone widgets, representing wall layout's children.
  final List<Stone> stones;

  /// Padding between stones.
  final double stonePadding;

  /// Same as [ListView].scrollController: "control the position to which this scroll view is scrolled".
  final ScrollController? scrollController;

  /// Same as [ListView].physics: "How the scroll view should respond to user input".
  final ScrollPhysics? physics;

  /// Same as [ListView].restorationId: used "to save and restore the scroll offset of the scrollable".
  final String? restorationId;

  /// Same as [ListView].dragStartBehavior: "Determines the way that drag start behavior is handled".
  final DragStartBehavior dragStartBehavior;

  /// Same as [ListView].clipBehavior: "ways to clip a widget's content".
  final Clip clipBehavior;

  /// Same as [ListView].primary: "Whether this is the primary scroll view associated with the parent [PrimaryScrollController]".
  final bool? primary;

  /// Same as [ListView].scrollDirection: "axis along which the scroll view scrolls".
  final Axis scrollDirection;

  /// Same as [ListView].reverse: "whether the scroll view scrolls in the reading direction".
  final bool reverse;

  WallLayout(
      {required this.layersCount,
        required this.stones,
      this.stonePadding = DEFAULT_BRICK_PADDING,
      this.scrollController,
      this.primary,
      this.physics,
      this.restorationId,
      this.clipBehavior = Clip.hardEdge,
      this.dragStartBehavior = DragStartBehavior.start,
      this.scrollDirection = Axis.vertical,
      this.reverse = false})
      : assert(stones.isNotEmpty),
        assert(layersCount >= 2,
            "You must define layers count from as an integer higher or equal to 2"),
        assert(stonePadding >= 0.0),
        assert(!(scrollController != null && primary == true),
        'Primary ScrollViews obtain their ScrollController via inheritance from a PrimaryScrollController widget. '
            'You cannot both set primary to true and pass an explicit controller.'
        ),
        super() {
    assert(this.stones.map((stone) => stone.id).toSet().length == this.stones.length, "Stones identifier must be unique.");
    this.stones.forEach((stone) {
      final constrainedSide = this.scrollDirection == Axis.vertical ? stone.width : stone.height;
      assert(constrainedSide <= this.layersCount,
          "Stone $stone is too big to fit in wall : constrained side ($constrainedSide) is higher than axisDivision ($layersCount)");
    });
  }

  @override
  State<StatefulWidget> createState() => _WallLayoutState();
}

class _WallLayoutState extends State<WallLayout> {
  late WallBuildHandler _handler;

  @override
  void initState() {
    super.initState();
    _resetHandler();
  }

  void _resetHandler() {
    _handler = WallBuildHandler(
      axisSeparations: this.widget.layersCount,
      stones: this.widget.stones,
      direction: this.widget.scrollDirection,
      reverse: this.widget.reverse,
    );
  }

  @override
  void didUpdateWidget(covariant WallLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget.layersCount != _handler.axisSeparations ||
        this.widget.scrollDirection != _handler.direction ||
        this.widget.reverse != _handler.reverse ||
        oldWidget.stones != this.widget.stones) {
      _resetHandler();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: this.widget.reverse,
      scrollDirection: this.widget.scrollDirection,
      restorationId: this.widget.restorationId,
      controller: this.widget.scrollController,
      physics: this.widget.physics,
      dragStartBehavior: this.widget.dragStartBehavior,
      primary: this.widget.primary,
      clipBehavior: this.widget.clipBehavior,
      child: CustomMultiChildLayout(
        delegate: _WallLayoutDelegate(handler: _handler, stonePadding: this.widget.stonePadding),
        children: this.widget.stones,
      ),
    );
  }
}

/// Delegates for CustomMultiChildLayout that position and size Stones.
class _WallLayoutDelegate extends MultiChildLayoutDelegate {
  final WallBuildHandler handler;
  final double stonePadding;

  _WallLayoutDelegate({required this.stonePadding, required this.handler, Listenable? relayout})
      : super(relayout: relayout);

  @override
  Size getSize(BoxConstraints constraints) {
    final constrainedSide =
        this.handler.direction == Axis.vertical ? constraints.maxWidth : constraints.maxHeight;

    final side = (constrainedSide / this.handler.axisSeparations);
    return this.handler.size * side;
  }

  @override
  void performLayout(Size size) {
    double side = ((this.handler.direction == Axis.vertical ? size.width : size.height) - this.stonePadding) /
        this.handler.axisSeparations;
    final initialPadding = Offset(this.stonePadding, this.stonePadding);
    this.handler.stones.forEach((stone) {
      Offset offset = this.handler.getPosition(stone) * side;
      Size size = Size(
        stone.width * side - this.stonePadding,
        stone.height * side - this.stonePadding,
      );

      positionChild(stone.id, initialPadding + offset);
      layoutChild(stone.id, BoxConstraints.tight(size));
    });
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
