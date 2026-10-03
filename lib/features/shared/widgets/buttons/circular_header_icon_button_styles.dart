import 'package:flutter/material.dart';

abstract final class CircularHeaderIconButtonStyles {
  static BoxDecoration containerDecoration(
    CircularHeaderIconButtonStyle style,
  ) => BoxDecoration(color: style.backgroundColor, shape: BoxShape.circle);
}

class CircularHeaderIconButtonStyle {
  const CircularHeaderIconButtonStyle.inkWell({
    required this.dimension,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
  }) : _feedback = _CircularHeaderButtonFeedback.inkWell,
       splashRadius = 0;

  const CircularHeaderIconButtonStyle.inkResponse({
    required this.dimension,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
    required this.splashRadius,
  }) : _feedback = _CircularHeaderButtonFeedback.inkResponse;

  final double dimension;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;
  final double splashRadius;
  final _CircularHeaderButtonFeedback _feedback;
  bool get usesInkResponse =>
      _feedback == _CircularHeaderButtonFeedback.inkResponse;
}

enum _CircularHeaderButtonFeedback { inkWell, inkResponse }
