import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/home_search_bar_styles.dart';

class HomeSearchFilterButton extends StatelessWidget {
  const HomeSearchFilterButton({
    required this.onTap,
    required this.activeFilterCount,
    super.key,
  });

  final VoidCallback onTap;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: activeFilterCount == 0
        ? 'Open product filters'
        : 'Open product filters, $activeFilterCount active',
    child: InkWell(
      key: const ValueKey('home-product-filter-button'),
      onTap: onTap,
      borderRadius: HomeSearchBarStyles.filterBorderRadius,
      child: SizedBox(
        width: HomeSearchBarStyles.filterButtonSize,
        height: HomeSearchBarStyles.filterButtonSize,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.tune_rounded,
              color: AgrisellColors.authGreen,
              size: HomeSearchBarStyles.filterIconSize,
            ),
            if (activeFilterCount > 0)
              Positioned(
                right: 2,
                top: 1,
                child: CircleAvatar(
                  radius: HomeSearchBarStyles.badgeRadius,
                  backgroundColor: AgrisellColors.authGreen,
                  child: Text(
                    '$activeFilterCount',
                    style: HomeSearchBarStyles.badgeText,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
