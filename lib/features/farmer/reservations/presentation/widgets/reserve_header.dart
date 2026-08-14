import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class ReserveHeader extends StatelessWidget {
  const ReserveHeader({
    required this.searchController,
    required this.onSearchChanged,
    required this.onMenuTap,
    super.key,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;
    final topPadding = (topInset > 0 ? topInset : 24.0) + 12;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        14,
      ),
      decoration: BoxDecoration(
        color: AgrisellColors.authGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ReserveSearchBar(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Open menu',
            child: InkResponse(
              onTap: onMenuTap,
              radius: 26,
              child: const HomeAssetIcon(
                asset: AgrisellAssets.iconMenu,
                size: 32,
                color: AgrisellColors.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReserveSearchBar extends StatelessWidget {
  const _ReserveSearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 13, color: AgrisellColors.brandBlack),
        decoration: InputDecoration(
          hintText: 'Search reservations',
          hintStyle: TextStyle(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.58),
            fontSize: 13,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: HomeAssetIcon(
              asset: AgrisellAssets.iconSearch,
              size: 23,
              color: AgrisellColors.brandBlack,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 43),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }
}
