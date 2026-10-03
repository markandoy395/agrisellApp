import 'package:agresell_app/features/farmer/reviews/presentation/styles/farmer_reviews_search_bar_styles.dart';
import 'package:flutter/material.dart';

import '../styles/farmer_reviews_screen_styles.dart';

class FarmerReviewsSearchBar extends StatelessWidget {
  const FarmerReviewsSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: FarmerReviewsScreenStyles.searchBarPadding,
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: FarmerReviewsSearchBarStyles.inputDecoration(
        controller,
        onChanged,
      ),
    ),
  );
}
