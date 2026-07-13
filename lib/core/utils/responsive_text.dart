import 'package:flutter/material.dart';

class RT {
  RT._();

  // The screen width your designs are built for (iPhone 14 = 390)
  static const double _baseWidth = 390.0;

  // Min/max clamp so text never gets unreadably tiny or huge
  static const double _minScale = 0.85;
  static const double _maxScale = 1.20;

  /// Call this to get a scaled font size.
  /// Usage: RT.fs(context, 16)
  static double fs(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / _baseWidth).clamp(_minScale, _maxScale);
    return size * scale;
  }
}