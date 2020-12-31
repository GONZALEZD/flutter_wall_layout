import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wall_layout/brick.dart';
import 'package:flutter_wall_layout/wall_build_handler.dart';

class WallLayout extends StatefulWidget {
  static const double DEFAULT_BRICK_PADDING = 16.0;

  final int axisDivisions;
  final List<Brick> bricks;
  final double brickPadding;
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
        this.bricks,
        this.brickPadding = DEFAULT_BRICK_PADDING,
        this.scrollController,
        this.primary,
        this.physics,
        this.restaurationId,
        this.clipBehavior =  Clip.hardEdge,
        this.dragStartBehavior = DragStartBehavior.start,
        this.scrollDirection = Axis.vertical,
        this.reverse = false})
      : super() {
    this.bricks.forEach((brick) {
      final constrainedSide = this.scrollDirection == Axis.vertical ? brick.width : brick.height;
      assert(constrainedSide <= this.axisDivisions,
      "Brick $brick is too big to fit in wall : constrained side ($constrainedSide) is higher than axisDivision ($axisDivisions)");
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
      bricks: this.widget.bricks,
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
        oldWidget.bricks != this.widget.bricks) {
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
        delegate: _WallLayoutDelegate(handler: _handler, brickPadding: this.widget.brickPadding),
        children: this.widget.bricks,
      ),
    );
  }
}

class _WallLayoutDelegate extends MultiChildLayoutDelegate {
  final WallBuildHandler handler;
  final double brickPadding;

  _WallLayoutDelegate({this.brickPadding, this.handler, Listenable relayout})
      : super(relayout: relayout);

  @override
  Size getSize(BoxConstraints constraints) {
    final constrainedSide =
    this.handler.direction == Axis.vertical ? constraints.maxWidth : constraints.maxHeight;

    final side = (constrainedSide - this.brickPadding) / this.handler.axisSeparations;
    return Size(this.handler.width.toDouble(), this.handler.height.toDouble()) * side;
  }

  @override
  void performLayout(Size size) {
    double side = (this.handler.direction == Axis.vertical ? size.width : size.height) /
        this.handler.axisSeparations;
    final initialPadding = Offset(this.brickPadding, this.brickPadding);
    this.handler.bricks.forEach((brick) {
      Offset offset = this.handler.getPosition(brick) * side;
      Size size = Size(
        brick.width * side - this.brickPadding,
        brick.height * side - this.brickPadding,
      );

      positionChild(brick.id, initialPadding + offset);
      layoutChild(brick.id, BoxConstraints.tight(size));
    });
  }

  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) => true;
}
