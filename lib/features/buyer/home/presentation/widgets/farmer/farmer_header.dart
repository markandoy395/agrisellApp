import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisellAssets.dart';
import 'package:agresell_app/core/constants/agrisellRoutes.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/common/basket_count_icon_button.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';

class FarmerHeader extends StatelessWidget {
  const FarmerHeader({
    required this.controller,
    required this.onQueryChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final headerTopPadding = (topInset > 0 ? topInset : 24.0) + 14;
    final horizontalPadding = width < 380 ? 14.0 : 18.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        headerTopPadding,
        horizontalPadding,
        width < 380 ? 14 : 16,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.authGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Find local farmers',
                  style: TextStyle(
                    color: AgrisellColors.surface,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: BasketController.instance,
                builder: (context, _) {
                  final basket = BasketController.instance;
                  return BasketCountIconButton(
                    count: basket.totalQuantity,
                    pulse: basket.pulse,
                    iconColor: AgrisellColors.surface,
                    badgeColor: AgrisellColors.surface,
                    badgeTextColor: AgrisellColors.authGreen,
                    badgeBorderColor: AgrisellColors.authGreen,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AgrisellRoutes.basket),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Browse harvests and connect directly.',
            style: TextStyle(
              color: AgrisellColors.forestSoft,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _FarmerSearchBar(
            controller: controller,
            onChanged: onQueryChanged,
            onClear: onClear,
          ),
        ],
      ),
    );
  }
}

class _FarmerSearchBar extends StatelessWidget {
  const _FarmerSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          color: AgrisellColors.headingGreen,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Search farmers, places, or produce',
          hintStyle: FarmerTextStyles.searchHint(context),
          prefixIcon: const Padding(
            padding: EdgeInsets.all(11),
            child: HomeAssetIcon(asset: AgrisellAssets.iconSearch, size: 22),
          ),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear farmer search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }
}
