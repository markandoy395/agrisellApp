import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutContentStyles {
  static double horizontalPadding(double screenWidth) =>
      screenWidth < 380 ? 8.0 : 10.0;

  static EdgeInsets scrollPadding(double horizontalPadding) =>
      EdgeInsets.fromLTRB(horizontalPadding, 10, horizontalPadding, 24);

  static const EdgeInsets addressPadding = EdgeInsets.fromLTRB(12, 11, 9, 12);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  static const TextStyle addressTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle contactNameTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle contactPhoneTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
}
