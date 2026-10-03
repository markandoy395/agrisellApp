import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class PayoutTextStyles {
  static const cashOutButton = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 13,
  );

  static TextStyle metricLabel(Color color) =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color);

  static TextStyle amount(Color color) =>
      TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color);

  static const mutedLabel = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w600,
  );

  static const heading = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const caption = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const cashOutTag = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AgrisellColors.authGreen,
  );

  static const orderLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.mutedText,
  );

  static const referenceLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const sectionHeading = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const screenTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const cashOutAction = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );

  static const tabLabel = TextStyle(fontWeight: FontWeight.w700, fontSize: 13);

  static const cardAmount = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: AgrisellColors.authGreen,
  );

  static const description = TextStyle(
    fontSize: 12,
    color: AgrisellColors.brandBlack,
    fontWeight: FontWeight.w600,
  );

  static TextStyle statusLabel(Color color) =>
      TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color);
}
