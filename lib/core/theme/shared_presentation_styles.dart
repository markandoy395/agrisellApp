import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Exact styles reused by multiple presentation components.
abstract final class SharedPresentationStyles {
  static const dropdownMenu = MenuStyle(
    backgroundColor: WidgetStatePropertyAll(AgrisellColors.surface),
  );
  static const titleBold = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

  static const caption = TextStyle(fontSize: 12);

  static const subtitleBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const bodyBold = TextStyle(fontSize: 13, fontWeight: FontWeight.w700);

  static const mutedCaption = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const body = TextStyle(fontSize: 13);

  static const forestCircle = BoxDecoration(
    color: AgrisellColors.forestSoft,
    shape: BoxShape.circle,
  );

  static const mutedCaptionSemibold = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const headingBodyExtraBold = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const originalPrice = TextStyle(
    color: Colors.red,
    fontSize: 12,
    decoration: TextDecoration.lineThrough,
    decorationColor: Colors.red,
    fontWeight: FontWeight.w600,
  );

  static const mutedText = TextStyle(color: AgrisellColors.mutedText);

  static const greenBodyExtraBold = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const mutedCaptionMedium = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const mutedCaptionSemiboldLoose = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const greenTitleExtraBold = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const bodyExtraBold = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const headingSubtitleExtraBold = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static const mutedCaptionCompact = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
  );

  static const inkBodyExtraBold = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const inkTitleExtraBold = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const headingTitleBlack = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const mutedCaptionLoose = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.35,
  );

  static const captionExtraBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const captionMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final borderedSurface = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const headingBodyBold = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const headingTitleExtraBold = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const captionSemibold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const mutedCaptionRelaxed = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
  );

  static const headingCaptionBold = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const greenCaptionExtraBold = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const errorCaption = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
  );

  static const mutedCaptionMediumLoose = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static const errorCaptionSemibold = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const mutedCaptionBold = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const titleExtraBold = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const extraBold = TextStyle(fontWeight: FontWeight.w800);

  static const subtitleExtraBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static final borderedField = BoxDecoration(
    color: AgrisellColors.fieldFill,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AgrisellColors.borderLine),
  );
}
