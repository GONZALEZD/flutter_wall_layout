import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Brick extends LayoutId {
  final int width;
  final int height;

  Brick({int id, Widget child, this.width, this.height}) : super(child: child, id: id);

  int get surface => width * height;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Object>('width', width));
    properties.add(DiagnosticsProperty<Object>('height', height));
  }
}