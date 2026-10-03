import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerSignUpStyles {
  static const stepIndicatorStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const orDividerTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const alreadyAccountStyle = TextStyle(fontSize: 13);

  static final loginButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    padding: EdgeInsets.zero,
    minimumSize: const Size(0, 38),
    textStyle: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
  );

  static ButtonStyle backButtonStyle(int step) => OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    minimumSize: Size(0, step == 1 ? 50 : 40),
    maximumSize: Size(double.infinity, step == 1 ? 50 : 40),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
  );
}
