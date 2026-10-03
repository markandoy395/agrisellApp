import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

abstract final class HomeProductScrollViewStyles {
  // Breakpoints & Layout calculations
  static const double compactBreakpoint = 380.0;

  static double horizontalPadding(double width) =>
      width < compactBreakpoint ? 12.0 : 16.0;

  static double contentPadding(double width) =>
      width < compactBreakpoint ? 12.0 : 14.0;

  static double contentGap(double width) =>
      width < compactBreakpoint ? 12.0 : 16.0;

  static double searchBottomGap(double width) =>
      width < compactBreakpoint ? 10.0 : 12.0;

  static double bannerHeight(double width) =>
      (width * 0.44).clamp(168.0, 196.0);

  static const double bottomSpacerHeight = 112.0;

  static EdgeInsets resultsHeaderPadding(
    double contentPadding,
    double contentGap,
  ) =>
      EdgeInsets.fromLTRB(contentPadding, contentGap, contentPadding, 12);

  static List<String> searchSuggestions(List<HomeProduct> products) => products
      .map((product) => product.name)
      .toSet()
      .take(8)
      .toList(growable: false);

  // Catalog Footer
  static const footerPadding = EdgeInsets.symmetric(vertical: 20);
  static const footerLoadingIndicatorSize = 18.0;
  static const footerLoadingStrokeWidth = 2.2;
  static const footerGap = SizedBox(width: 10);

  static final footerLoadingTextStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.brandBlack.withValues(alpha: 0.6),
    fontWeight: FontWeight.w500,
  );

  static final footerEndTextStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.brandBlack.withValues(alpha: 0.45),
    fontWeight: FontWeight.w500,
  );

  // Deals Quick Banner
  static final dealsBorderRadius = BorderRadius.circular(14);
  static const dealsPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );
  static final dealsDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: dealsBorderRadius,
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );
  static const dealsIconContainerPadding = EdgeInsets.all(8);
  static final dealsIconContainerDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.2),
    shape: BoxShape.circle,
  );
  static const dealsTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static const dealsSubtitleStyle = TextStyle(
    color: Colors.white70,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
}
