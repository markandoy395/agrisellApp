import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class OtpVerificationSheetStyles {
  static const sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  );

  static const sheetPadding = EdgeInsets.fromLTRB(24, 20, 24, 24);

  static final sheetHandleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );

  static const sheetTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const sheetBody = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
    height: 1.4,
  );

  static final closeButton = FilledButton.styleFrom(
    backgroundColor: AgrisellColors.forestSoft,
    foregroundColor: AgrisellColors.headingGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

  static const boldButtonText = TextStyle(fontWeight: FontWeight.w700);

  static final backButton = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.headingGreen,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );

  static const backButtonText = TextStyle(fontWeight: FontWeight.w600);

  static ButtonStyle supportButton(Color accentColor) => FilledButton.styleFrom(
    backgroundColor: accentColor,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 0,
  );

  static const supportTilePadding = EdgeInsets.all(12);

  static final supportTileDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const supportTileTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const supportTileDetail = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );
}
