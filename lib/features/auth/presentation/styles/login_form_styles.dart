import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class LoginFormStyles {
  static final textButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    minimumSize: const Size(0, 40),
    padding: EdgeInsets.zero,
    textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
  );

  static final textButtonStyle2 = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    padding: EdgeInsets.zero,
    minimumSize: const Size(0, 40),
    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  );
}
