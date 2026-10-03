import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BasketSuggestionsStyles {
  // Colors
  static const Color iconBackgroundColor = AgrisellColors.forestSoft;
  static const Color iconColor = AgrisellColors.authGreen;
  static const Color cardBackground = AgrisellColors.surface;
  static const Color borderColor = AgrisellColors.borderLine;
  static final Color actionButtonBackground = AgrisellColors.surface.withValues(
    alpha: 0.94,
  );
  static const Color mutedIconColor = AgrisellColors.mutedText;

  // Dimensions & Gaps
  static const double gridHeight = 226.0;
  static const double compactCardWidth = 154.0;
  static const double regularCardWidth = 166.0;
  static const double thumbnailHeight = 126.0;
  static const double labelIconSize = 21.0;
  static const double stateIconSize = 21.0;
  static const double swipeIconSize = 20.0;
  static const double cartActionIconSize = 17.0;
  static const double cartActionSize = 34.0;
  static const double labelIconContainerSize = 38.0;
  static const double itemSpacing = 12.0;
  static const double headerGap = 12.0;
  static const double titleSubtitleGap = 4.0;
  static const double iconToTextGap = 11.0;
  static const double stateIconToTextGap = 10.0;
  static const double cardTitleToSellerGap = 5.0;

  // Radii
  static final BorderRadius cardRadius = BorderRadius.circular(16);
  static final BorderRadius stateRadius = BorderRadius.circular(10);
  static final BorderRadius labelIconRadius = BorderRadius.circular(12);

  // Paddings
  static const EdgeInsets statePadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 16,
  );
  static const EdgeInsets cardContentPadding = EdgeInsets.fromLTRB(
    10,
    9,
    10,
    10,
  );
  static const EdgeInsets swipeIconPadding = EdgeInsets.only(top: 7);
  static const EdgeInsets actionButtonPosition = EdgeInsets.only(
    top: 8,
    right: 8,
  );

  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    height: 1.15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle headerSubtitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle stateMessage = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle productTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sellerName = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.15,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle productPrice = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  // Decorations
  static final BoxDecoration labelIconDecoration = BoxDecoration(
    color: iconBackgroundColor,
    borderRadius: labelIconRadius,
  );

  static final BoxDecoration stateDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: stateRadius,
    border: Border.all(color: borderColor),
  );

  static final BoxDecoration cardDecoration = BoxDecoration(
    borderRadius: cardRadius,
    border: Border.all(color: borderColor),
  );

  static double cardWidthForScreenWidth(double width) =>
      width < 380 ? compactCardWidth : regularCardWidth;

  // SnackBar
  static SnackBar snackBar(String message) => SnackBar(content: Text(message));
}
