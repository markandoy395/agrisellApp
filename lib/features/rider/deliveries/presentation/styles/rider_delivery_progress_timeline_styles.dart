import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryProgressTimelineStyles {
  static BoxDecoration containerDecoration(Color color) =>
      BoxDecoration(shape: BoxShape.circle, color: color);

  static TextStyle textStyle(bool complete, bool active) => TextStyle(
    color: complete || active
        ? AgrisellColors.headingGreen
        : AgrisellColors.mutedText,
    fontSize: 13,
    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
  );
}
