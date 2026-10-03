import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RoleSelectionStyles {
  static const description =
      'Choose Farmer if you want to sell fresh harvests. Choose Buyer if you '
      'want to shop local produce, or Rider if you deliver orders.';

  static double cardHeight(Size size) {
    final compact = size.height < 720;
    return (size.height * (compact ? .82 : .57)).clamp(440.0, 580.0);
  }

  static EdgeInsets headerPadding(bool compact) =>
      EdgeInsets.only(top: compact ? 16 : 22);

  static double logoWidthMin(double width) => width * .48;
  static double logoWidthMax(double width) => width * .53;

  static final cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: .09),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static EdgeInsets cardPadding(double bottomPadding) =>
      EdgeInsets.fromLTRB(24, 15, 24, 22 + bottomPadding);

  static final indicatorDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
  );

  static const questionTextStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    height: 1.05,
  );

  static const subtitleTextStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 14,
  );
}
