import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class RiderDeliveryReferenceStyles {
  static const radius = BorderRadius.all(Radius.circular(16));
  static const background = AgrisellColors.pageBackground;
  static final title = AppTypography.title.copyWith(
    fontWeight: FontWeight.w700,
    color: AgrisellColors.headingGreen,
  );
  static final heading = title.copyWith(
    fontSize: 20,
    color: AgrisellColors.surface,
  );
  static final body = AppTypography.body.copyWith(
    color: AgrisellColors.headingGreen,
    height: 1.45,
  );
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
    height: 1.4,
  );
  static final strongCaption = caption.copyWith(
    fontWeight: FontWeight.w600,
    color: AgrisellColors.headingGreen,
  );
  static final whiteCaption = caption.copyWith(color: AgrisellColors.surface);
  static final earning = title.copyWith(
    fontSize: 22,
    color: AgrisellColors.authGreen,
  );
  static const header = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AgrisellColors.forestDark, AgrisellColors.authGreen],
    ),
  );
  static final card = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: radius,
    border: Border.all(color: AgrisellColors.borderLine),
  );
  static BoxDecoration tint(Color color) => BoxDecoration(
    color: color.withValues(alpha: .10),
    borderRadius: BorderRadius.circular(12),
  );
  static BoxDecoration marker(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    border: Border.all(color: AgrisellColors.surface, width: 3),
  );
  static final navigate = TextButton.styleFrom(
    foregroundColor: AgrisellColors.statusBlueText,
    backgroundColor: AgrisellColors.accentBlue.withValues(alpha: .14),
    minimumSize: const Size(48, 36),
    maximumSize: Size.infinite,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
  );
  static final mapButton = navigate.copyWith(
    backgroundColor: const WidgetStatePropertyAll(AgrisellColors.surface),
  );
  static final headerWaybill = TextButton.styleFrom(
    foregroundColor: AgrisellColors.surface,
    minimumSize: const Size(56, 64),
    maximumSize: Size.infinite,
    padding: const EdgeInsets.all(4),
    textStyle: AppTypography.caption,
  );
  static ButtonStyle quickAction(Color color) => OutlinedButton.styleFrom(
    foregroundColor: color,
    backgroundColor: AgrisellColors.surface,
    minimumSize: const Size(0, 68),
    maximumSize: Size.infinite,
    side: const BorderSide(color: AgrisellColors.borderLine),
    shape: const RoundedRectangleBorder(borderRadius: radius),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
    textStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w500),
  );
  static const mapHeight = 220.0;
  static const mapStroke = AgrisellColors.statusBlueText;
  static final timelineLabel = AppTypography.caption.copyWith(
    fontSize: 10,
    color: AgrisellColors.mutedText,
    height: 1.3,
  );
  static TextStyle timelineText(bool reached) => timelineLabel.copyWith(
    color: reached ? AgrisellColors.authGreen : AgrisellColors.mutedText,
    fontWeight: reached ? FontWeight.w600 : FontWeight.w400,
  );
}
