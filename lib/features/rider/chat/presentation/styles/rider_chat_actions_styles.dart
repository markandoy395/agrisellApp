import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderChatActionsStyles {
  static final textButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
  );
}
