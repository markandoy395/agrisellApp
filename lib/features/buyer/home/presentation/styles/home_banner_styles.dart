import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_banner_promo_styles.dart';

export 'package:agresell_app/features/buyer/home/presentation/styles/home_banner_promo_styles.dart';

/// Shared visual definitions and responsive variants for home promotions.
abstract final class HomeBannerStyles {
  static double singleCenterInset(bool compact) => compact ? 52 : 58;
  static double singleSideWidth(bool compact) => compact ? 86 : 96;
  static double singlePeekGap(bool compact) => compact ? 10 : 12;

  static EdgeInsets singleBannerPadding(double centerInset) =>
      EdgeInsets.symmetric(horizontal: centerInset);

  static final leftPeekDecoration = _peekDecoration(const [
    Color(0xFF348F5B),
    Color(0xFFAADB5B),
  ]);
  static final rightPeekDecoration = _peekDecoration(const [
    Color(0xFF202322),
    Color(0xFF0F6039),
  ]);

  static BoxDecoration sidePeekDecoration(bool isLeft) =>
      isLeft ? leftPeekDecoration : rightPeekDecoration;

  static BoxDecoration _peekDecoration(List<Color> colors) => BoxDecoration(
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
        blurRadius: 14,
        offset: const Offset(0, 7),
      ),
    ],
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: colors,
    ),
  );

  static const indicatorPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 5,
  );

  static final indicatorDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.20),
    borderRadius: BorderRadius.circular(20),
  );

  static const dotSpacing = EdgeInsets.only(right: 4);
  static EdgeInsets indicatorDotMargin(int index, int count) =>
      index == count - 1 ? EdgeInsets.zero : dotSpacing;

  static final selectedDotDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(6),
  );
  static final unselectedDotDecoration = selectedDotDecoration.copyWith(
    color: AgrisellColors.surface.withValues(alpha: 0.48),
  );
  static BoxDecoration indicatorDotDecoration(bool selected) =>
      selected ? selectedDotDecoration : unselectedDotDecoration;

  static const compactExpiryPadding = EdgeInsets.symmetric(
    horizontal: 7,
    vertical: 5,
  );

  static const regularExpiryPadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 6,
  );

  static EdgeInsets expiryPadding(bool compact) =>
      compact ? compactExpiryPadding : regularExpiryPadding;

  static final expiryDecoration = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.10),
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.22)),
    borderRadius: BorderRadius.circular(9),
  );

  static final expiryIconDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
  );

  static const compactExpiryCaption = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 7,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.45,
  );

  static const regularExpiryCaption = TextStyle(
    color: AgrisellColors.authGreen,
    fontFamily: AppTypography.fontFamily,
    fontSize: 8,
    height: 1,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.45,
  );

  static TextStyle expiryCaption(bool compact) =>
      compact ? compactExpiryCaption : regularExpiryCaption;

  static const compactExpiryDate = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 9,
    height: 1,
    fontWeight: FontWeight.w700,
  );

  static const regularExpiryDate = TextStyle(
    color: AgrisellColors.brandBlack,
    fontFamily: AppTypography.fontFamily,
    fontSize: 10,
    height: 1,
    fontWeight: FontWeight.w700,
  );

  static TextStyle expiryDate(bool compact) =>
      compact ? compactExpiryDate : regularExpiryDate;

  // Re-exported promo styles delegation
  static BoxDecoration get promoDecoration =>
      HomeBannerPromoStyles.promoDecoration;
  static TextStyle prefixText(bool compact) =>
      HomeBannerPromoStyles.prefixText(compact);
  static TextStyle highlightText(bool compact) =>
      HomeBannerPromoStyles.highlightText(compact);
  static TextStyle subtitleText(bool compact) =>
      HomeBannerPromoStyles.subtitleText(compact);
  static const campaignPadding = HomeBannerPromoStyles.campaignPadding;
  static BoxDecoration get campaignDecoration =>
      HomeBannerPromoStyles.campaignDecoration;
  static TextStyle campaignText(bool compact) =>
      HomeBannerPromoStyles.campaignText(compact);
  static TextStyle productText(bool compact) =>
      HomeBannerPromoStyles.productText(compact);
  static const shopPadding = HomeBannerPromoStyles.shopPadding;
  static BoxDecoration get shopDecoration =>
      HomeBannerPromoStyles.shopDecoration;
  static const shopText = HomeBannerPromoStyles.shopText;

  static const carouselPadding = EdgeInsets.symmetric(horizontal: 6);
  static const pagePadding = EdgeInsets.symmetric(horizontal: 7);
}
