import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ChatMessageFieldStyles {
  static final counter = AppTypography.caption.copyWith(
    fontSize: 10,
    color: AgrisellColors.mutedText,
  );
  static InputDecoration decoration(InputDecoration base) =>
      base.copyWith(counterStyle: counter);
}
