import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/controllers/farmer_reviews_controller.dart';

import '../styles/farmer_review_action_styles.dart';
import '../styles/farmer_reviews_styles.dart';

class FarmerReviewsFilterBar extends StatelessWidget {
  const FarmerReviewsFilterBar({
    required this.selectedFilter,
    required this.onFilterSelected,
    this.moderatedCount = 0,
    super.key,
  });

  final FarmerReviewsFilter selectedFilter;
  final ValueChanged<FarmerReviewsFilter> onFilterSelected;
  final int moderatedCount;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: FarmerReviewsStyles.horizontal,
      padding: FarmerReviewsStyles.filterPadding,
      child: Row(
        children: FarmerReviewsFilter.values.map((filter) {
          final isSelected = filter == selectedFilter;
          final label =
              filter == FarmerReviewsFilter.withNotes && moderatedCount > 0
              ? 'With Notes ($moderatedCount)'
              : filter.label;

          return Padding(
            padding: FarmerReviewsStyles.filterSpacing,
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onFilterSelected(filter),
              selectedColor: AgrisellColors.authGreen,
              backgroundColor: AgrisellColors.surface,
              labelStyle: isSelected
                  ? FarmerReviewActionStyles.selectedLabel
                  : FarmerReviewActionStyles.unselectedLabel,
              shape: isSelected
                  ? FarmerReviewActionStyles.selectedShape
                  : FarmerReviewActionStyles.unselectedShape,
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }
}
