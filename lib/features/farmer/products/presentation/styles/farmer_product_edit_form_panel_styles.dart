import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerProductEditFormPanelStyles {
  // Panel Layout
  static const panelDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
  );

  static const panelPadding = EdgeInsets.fromLTRB(25, 31, 25, 30);
  static const footerPadding = EdgeInsets.fromLTRB(25, 12, 25, 24);

  static const rowSpacing = SizedBox(height: 20);
  static const actionSpacing = SizedBox(height: 36);

  // Active Promotion Banner
  static const bannerPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );

  static final activeBannerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.authGreen.withValues(alpha: 0.3)),
  );

  static const activeBannerTitleStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );

  static const activeBannerNoticeStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final editDiscountButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );

  static final removeDiscountButtonStyle = TextButton.styleFrom(
    foregroundColor: AgrisellColors.statusRedText,
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 8),
  );

  // Inactive Discount Banner
  static final inactiveBannerDecoration = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const inactiveBannerTitleStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const inactiveBannerNoticeStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static final putOnSaleButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    side: const BorderSide(color: AgrisellColors.authGreen),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  static const putOnSaleButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
