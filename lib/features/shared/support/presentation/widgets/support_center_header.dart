import 'package:agresell_app/features/shared/support/presentation/styles/support_center_header_styles.dart';
import 'package:flutter/material.dart';

import '../styles/support_center_styles.dart';

class SupportCenterHeader extends StatelessWidget {
  const SupportCenterHeader({
    required this.searchController,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    super.key,
  });

  final TextEditingController searchController;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: SupportCenterStyles.headerColor,
      padding: SupportCenterStyles.headerPadding,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: SupportCenterHeaderStyles.inputDecoration(
              searchController,
              onSearchChanged,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip('all', 'All Tickets'),
                const SizedBox(width: 8),
                _filterChip('open', 'Active / In Progress'),
                const SizedBox(width: 8),
                _filterChip('resolved', 'Resolved / Closed'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String filterKey, String label) {
    final isSelected = selectedFilter == filterKey;
    return ChoiceChip(
      showCheckmark: false,
      label: Text(label),
      selected: isSelected,
      selectedColor: SupportCenterStyles.chipSelectedBackground,
      backgroundColor: SupportCenterStyles.chipBackground,
      labelStyle: SupportCenterStyles.chipTextStyle(isSelected: isSelected),
      shape: RoundedRectangleBorder(
        borderRadius: SupportCenterStyles.chipRadius,
        side: SupportCenterStyles.chipBorderSide(isSelected: isSelected),
      ),
      onSelected: (_) => onFilterChanged(filterKey),
    );
  }
}
