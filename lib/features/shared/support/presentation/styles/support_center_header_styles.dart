import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/support/presentation/styles/support_center_styles.dart';

abstract final class SupportCenterHeaderStyles {
  static InputDecoration inputDecoration(
    TextEditingController searchController,
    void Function(String) onSearchChanged,
  ) => InputDecoration(
    hintText: 'Search tickets by subject, #ID, or category...',
    hintStyle: SupportCenterStyles.searchHintStyle,
    prefixIcon: const Icon(
      Icons.search_rounded,
      size: 20,
      color: AgrisellColors.mutedText,
    ),
    suffixIcon: searchController.text.isNotEmpty
        ? IconButton(
            icon: const Icon(Icons.clear_rounded, size: 18),
            onPressed: () {
              searchController.clear();
              onSearchChanged('');
            },
          )
        : null,
    filled: true,
    fillColor: AgrisellColors.searchBackground,
    contentPadding: SupportCenterStyles.searchContentPadding,
    border: OutlineInputBorder(
      borderRadius: SupportCenterStyles.searchBorderRadius,
      borderSide: BorderSide.none,
    ),
  );
}
