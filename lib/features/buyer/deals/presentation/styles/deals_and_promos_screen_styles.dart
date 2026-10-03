import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class DealsAndPromosScreenStyles {
  // App Bar & Tabs
  static const appBarBackground = AgrisellColors.authGreen;
  static const appBarElevation = 0.0;
  static const appBarTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const tabBarPreferredSize = Size.fromHeight(48);
  static const tabLabelColor = AgrisellColors.authGreen;
  static const tabUnselectedLabelColor = AgrisellColors.mutedText;
  static const tabIndicatorColor = AgrisellColors.authGreen;
  static const tabIndicatorWeight = 3.0;
  static const tabLabelStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  // Search Field
  static const searchFieldPadding = EdgeInsets.fromLTRB(16, 12, 16, 8);
  static const searchHintStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.mutedText,
  );
  static const searchPrefixIcon = Icon(
    Icons.search_rounded,
    color: AgrisellColors.mutedText,
  );
  static const searchContentPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static final searchBorderRadius = BorderRadius.circular(12);

  static InputDecoration searchInputDecoration({
    required bool hasQuery,
    required VoidCallback onClear,
  }) {
    final baseBorder = OutlineInputBorder(
      borderRadius: searchBorderRadius,
      borderSide: const BorderSide(color: AgrisellColors.borderLine),
    );
    return InputDecoration(
      hintText: 'Search vouchers by name or code...',
      hintStyle: searchHintStyle,
      prefixIcon: searchPrefixIcon,
      suffixIcon: hasQuery
          ? IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18),
              onPressed: onClear,
            )
          : null,
      filled: true,
      fillColor: AgrisellColors.surface,
      contentPadding: searchContentPadding,
      border: baseBorder,
      enabledBorder: baseBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: searchBorderRadius,
        borderSide: const BorderSide(
          color: AgrisellColors.authGreen,
          width: 1.5,
        ),
      ),
    );
  }

  // Error State
  static const errorTextStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 14,
  );
  static final tryAgainButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
  );

  // Empty State
  static const emptyIconSize = 56.0;
  static const emptyTitleStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const emptyMessageStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
  );
  static const emptyMessagePadding = EdgeInsets.symmetric(horizontal: 36);

  // List View
  static const listPadding = EdgeInsets.fromLTRB(16, 12, 16, 24);
  static const listSeparator = SizedBox(height: 12);
}
