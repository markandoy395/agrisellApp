import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatProductThumbnailStyles {
  static BoxDecoration containerDecoration(double borderRadius) =>
      BoxDecoration(
        color: AgrisellColors.searchBackground,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AgrisellColors.borderLine),
      );
}
