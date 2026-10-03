import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_header_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/common/basket_count_icon_button.dart';

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
      decoration: FarmerHeaderStyles.containerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Find local farmers',
                  style: FarmerHeaderStyles.findLocalFarmersText,
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
            style: FarmerHeaderStyles.browseHarvestsAndConnectDirectlyText,
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
      decoration: FarmerHeaderStyles.containerDecoration2,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: FarmerHeaderStyles.textStyle,
        decoration: FarmerHeaderStyles.inputDecoration(
          context,
          controller,
          onClear,
        ),
      ),
    );
  }
}
