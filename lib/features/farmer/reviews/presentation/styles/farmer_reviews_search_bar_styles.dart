import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/styles/farmer_reviews_screen_styles.dart';

abstract final class FarmerReviewsSearchBarStyles {
  static InputDecoration inputDecoration(
    TextEditingController controller,
    void Function(String) onChanged,
  ) => InputDecoration(
    hintText: 'Search by product, buyer, or comment...',
    hintStyle: FarmerReviewsScreenStyles.searchHintStyle,
    prefixIcon: const Icon(
      Icons.search_rounded,
      color: AgrisellColors.authGreen,
      size: 20,
    ),
    suffixIcon: controller.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear_rounded, size: 18),
            onPressed: () {
              controller.clear();
              onChanged('');
            },
          )
        : null,
    filled: true,
    fillColor: AgrisellColors.surface,
    contentPadding: FarmerReviewsScreenStyles.searchContentPadding,
    border: OutlineInputBorder(
      borderRadius: FarmerReviewsScreenStyles.searchInputBorderRadius,
      borderSide: FarmerReviewsScreenStyles.searchBorderSide,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: FarmerReviewsScreenStyles.searchInputBorderRadius,
      borderSide: FarmerReviewsScreenStyles.searchBorderSide,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: FarmerReviewsScreenStyles.searchInputBorderRadius,
      borderSide: FarmerReviewsScreenStyles.searchFocusedBorderSide,
    ),
  );
}
