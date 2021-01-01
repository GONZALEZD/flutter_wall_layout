import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Stone extends LayoutId {
  final int width;
  final int height;

  Stone({int id, Widget child, this.width, this.height})
      : assert(width != null),
        assert(width > 0),
        assert(height != null),
        assert(height > 0),
        super(child: child, id: id);

  int get surface => width * height;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('width', width));
    properties.add(DiagnosticsProperty<Object>('height', height));
  }
}