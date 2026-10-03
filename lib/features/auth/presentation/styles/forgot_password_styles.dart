import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ForgotPasswordStyles {
  static const promptTextStyle = TextStyle(
    color: AgrisellColors.headingGreenAlt,
    fontSize: 15,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static final backToLoginButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    textStyle: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
    ),
  );

  static const errorTextStyle = TextStyle(
    color: Color(0xFFB3261E),
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
