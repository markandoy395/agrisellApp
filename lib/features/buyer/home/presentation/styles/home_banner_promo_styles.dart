import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class HomeBannerPromoStyles {
  static final promoDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static const compactPrefixText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
  );

  static const regularPrefixText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w500,
  );

  static TextStyle prefixText(bool compact) =>
      compact ? compactPrefixText : regularPrefixText;

  static const compactHighlightText = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w800,
  );

  static const regularHighlightText = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w800,
  );

  static TextStyle highlightText(bool compact) =>
      compact ? compactHighlightText : regularHighlightText;

  static const compactSubtitleText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 14.0,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static const regularSubtitleText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 15.0,
    height: 1,
    fontWeight: FontWeight.w500,
  );

  static TextStyle subtitleText(bool compact) =>
      compact ? compactSubtitleText : regularSubtitleText;

  static const campaignPadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 3,
  );

  static final campaignDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(5),
  );

  static const compactCampaignText = TextStyle(
    color: AgrisellColors.surface,
    fontFamily: AppTypography.fontFamily,
    fontSize: 7,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.35,
  );

  static const regularCampaignText = TextStyle(
    color: AgrisellColors.surface,
    fontFamily: AppTypography.fontFamily,
    fontSize: 8,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.35,
  );

  static TextStyle campaignText(bool compact) =>
      compact ? compactCampaignText : regularCampaignText;

  static const compactProductText = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 19.0,
    height: 0.92,
    fontWeight: FontWeight.w800,
  );

  static const regularProductText = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 21.0,
    height: 0.92,
    fontWeight: FontWeight.w800,
  );

  static TextStyle productText(bool compact) =>
      compact ? compactProductText : regularProductText;

  static const shopPadding = EdgeInsets.symmetric(horizontal: 9, vertical: 6);

  static final shopDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.circular(12),
  );

  static const shopText = TextStyle(
    color: AgrisellColors.surface,
    fontFamily: AppTypography.fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );
}
