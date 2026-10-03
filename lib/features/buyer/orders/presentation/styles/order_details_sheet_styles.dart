import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OrderDetailsSheetStyles {
  static final filledButtonStyle = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.statusPurpleText,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static const trackRefundStatusText = TextStyle(fontWeight: FontWeight.w700);

  static final filledButtonStyle2 = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static const valueText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
