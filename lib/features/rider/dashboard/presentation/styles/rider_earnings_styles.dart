import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderEarningsStyles {
  // Colors
  static const Color backgroundColor = AgrisellColors.homeBackground;
  static const Color modalBackgroundColor = AgrisellColors.surface;
  static const Color headerIconColor = AgrisellColors.surface;

  // Paddings & Spacings
  static const EdgeInsets listPadding = EdgeInsets.all(14);
  static const double chipSpacing = 8.0;
  static const double chipRunSpacing = 8.0;
  static const SizedBox sectionSpacing = SizedBox(height: 14);
  static const SizedBox cardSpacing = SizedBox(height: 12);
  static const SizedBox historySpacing = SizedBox(height: 14);
  static const EdgeInsets breakdownRowPadding = EdgeInsets.symmetric(
    vertical: 2.5,
  );

  // Typography
  static const TextStyle chipLabelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle netEarningsStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle netEarningsSubtextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle manageMethodsTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.authGreen,
  );

  static const TextStyle cashOutTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static const TextStyle breakdownLabelStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle breakdownValueStyle([Color? color]) => TextStyle(
    color: color ?? AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  // Button Styles
  static final ButtonStyle manageMethodsButtonStyle = TextButton.styleFrom(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static final ButtonStyle cashOutButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    elevation: 0,
  );

  // Modal Shapes
  static const ShapeBorder modalShape = RoundedRectangleBorder(
    borderRadius: verticalTopRadius,
  );

  static const BorderRadius verticalTopRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );
}
