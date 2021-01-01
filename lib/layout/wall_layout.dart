import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/layout/stone.dart';
import 'package:flutter_wall_layout/layout/wall_build_handler.dart';

class WallLayout extends StatefulWidget {
  static const double DEFAULT_BRICK_PADDING = 16.0;

  final int axisDivisions;
  final List<Stone> stones;
  final double stonePadding;
  final ScrollController scrollController;
  final ScrollPhysics physics;
  final String restaurationId;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final bool primary;

  final Axis scrollDirection;
  final bool reverse;

  WallLayout(
      {this.axisDivisions,
      this.stones,
      this.stonePadding = DEFAULT_BRICK_PADDING,
      this.scrollController,
      this.primary,
      this.physics,
      this.restaurationId,
      this.clipBehavior = Clip.hardEdge,
      this.dragStartBehavior = DragStartBehavior.start,
      this.scrollDirection = Axis.vertical,
      this.reverse = false})
      : assert(stones != null && stones.isNotEmpty),
        assert(axisDivisions != null && axisDivisions >= 2,
            "You must define divisions from main axis, and higher or equal to 2"),
        assert(stonePadding != null && stonePadding >= 0.0),
        assert(!(scrollController != null && primary == true),
        'Primary ScrollViews obtain their ScrollController via inheritance from a PrimaryScrollController widget. '
            'You cannot both set primary to true and pass an explicit controller.'
        ),
        super() {
    assert(this.stones.map((stone) => stone.id).toSet().length == this.stones.length, "Stones identifier must be unique.");
    this.stones.forEach((stone) {
      final constrainedSide = this.scrollDirection == Axis.vertical ? stone.width : stone.height;
      assert(constrainedSide <= this.axisDivisions,
          "Stone $stone is too big to fit in wall : constrained side ($constrainedSide) is higher than axisDivision ($axisDivisions)");
    });
  }

  @override
  State<StatefulWidget> createState() => _WallLayoutState();
}

class _WallLayoutState extends State<WallLayout> {
  WallBuildHandler _handler;

  @override
  void initState() {
    super.initState();
    _resetHandler();
  }

  void _resetHandler() {
    _handler = WallBuildHandler(
      axisSeparations: this.widget.axisDivisions,
      stones: this.widget.stones,
      direction: this.widget.scrollDirection,
      reverse: this.widget.reverse,
    );
    _handler.setup();
  }

  @override
  void didUpdateWidget(covariant WallLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (this.widget.axisDivisions != _handler.axisSeparations ||
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
      restorationId: this.widget.restaurationId,
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

class _WallLayoutDelegate extends MultiChildLayoutDelegate {
  final WallBuildHandler handler;
  final double stonePadding;

  _WallLayoutDelegate({this.stonePadding, this.handler, Listenable relayout})
      : super(relayout: relayout);

  @override
  Size getSize(BoxConstraints constraints) {
    final constrainedSide =
        this.handler.direction == Axis.vertical ? constraints.maxWidth : constraints.maxHeight;

    final side = (constrainedSide - this.stonePadding) / this.handler.axisSeparations;
    return this.handler.size * side;
  }

  @override
  void performLayout(Size size) {
    double side = (this.handler.direction == Axis.vertical ? size.width : size.height) /
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
