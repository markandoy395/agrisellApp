import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';
import 'rider_home_design_styles.dart';

abstract final class RiderReferenceStyles {
  static Paint fill(Color color) => Paint()..color = color;
  static const blue = AgrisellColors.statusBlueText;
  static const green = RiderHomeDesignStyles.green;
  static const muted = RiderHomeDesignStyles.muted;
  static const ink = RiderHomeDesignStyles.ink;
  static const title = RiderHomeDesignStyles.title;
  static const body = RiderHomeDesignStyles.body;
  static const caption = RiderHomeDesignStyles.caption;
  static const value = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    color: ink,
    fontWeight: FontWeight.w700,
  );
  static const fee = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 13,
    color: green,
    fontWeight: FontWeight.w700,
  );
  static const small = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    color: muted,
    height: 1.3,
  );
  static const link = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    color: blue,
  );
  static const progressText = TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 11,
    color: AgrisellColors.statusOrangeText,
    fontWeight: FontWeight.w600,
  );
  static const progressBadge = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );
  static const nextMove = BoxDecoration(
    color: AgrisellColors.statusBlueBackground,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );
  static final listRow = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static final neutralButton = TextButton.styleFrom(
    backgroundColor: AgrisellColors.pageBackground,
    foregroundColor: ink,
    minimumSize: const Size(0, 42),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
  static final linkButton = TextButton.styleFrom(
    foregroundColor: blue,
    minimumSize: const Size(0, 30),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.symmetric(horizontal: 4),
    textStyle: const TextStyle(
      fontFamily: AppTypography.fontFamily,
      fontSize: 12,
    ),
  );
  static const nav = BoxDecoration(
    color: AgrisellColors.surface,
    border: Border(top: BorderSide(color: AgrisellColors.borderLine)),
  );
  static TextStyle navLabel(bool selected) => TextStyle(
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    color: selected ? green : muted,
  );
  static BoxDecoration indicator(bool selected) => BoxDecoration(
    color: selected ? green : Colors.transparent,
    borderRadius: BorderRadius.circular(2),
  );
  static BoxDecoration stop(bool pickup) => BoxDecoration(
    shape: BoxShape.circle,
    color: pickup ? green : AgrisellColors.mutedText,
    border: Border.all(
      color: pickup ? AgrisellColors.forestSoft : AgrisellColors.borderLine,
      width: 4,
    ),
  );
}
