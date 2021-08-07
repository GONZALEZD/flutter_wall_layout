import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// A Stone Widget is a widget proxy defining stone's size (width and height).
/// It's rendered object is optimized thanks to it's id property.
/// Depending on the wall (rendered) direction, a stone width or height cannot exceed the wall layers count.
/// If so, the [WallLayout] constructor throws an error.
/// Added to that, [WallLayout] constructor check that every Stone identifier is unique.
class Stone extends LayoutId {

  /// Stone width (relative to the number of wall layers count). Must be higher or equal to 1.
  final int width;

  /// Stone height (relative to the number of wall layers count). Must be higher or equal to 1.
  final int height;

  Stone({required int id, required Widget child, required this.width, required this.height})
      : assert(width > 0),
        assert(height > 0),
        super(child: child, id: id);

  /// Computes the surface area of the stone.
  int get surface => width * height;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('width', width));
    properties.add(DiagnosticsProperty<Object>('height', height));
  }
}
