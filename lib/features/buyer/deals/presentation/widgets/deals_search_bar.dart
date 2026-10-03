import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/deals/presentation/styles/deals_and_promos_screen_styles.dart';

class DealsSearchBar extends StatelessWidget {
  const DealsSearchBar({
    required this.controller,
    required this.hasQuery,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: DealsAndPromosScreenStyles.searchFieldPadding,
      child: TextField(
        controller: controller,
        decoration: DealsAndPromosScreenStyles.searchInputDecoration(
          hasQuery: hasQuery,
          onClear: onClear,
        ),
        onChanged: onChanged,
      ),
    );
  }
}
