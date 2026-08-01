import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

class ReserveHeader extends StatelessWidget {
  const ReserveHeader({super.key});

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
          const Expanded(child: _ReserveSearchBar()),
          const SizedBox(width: 10),
          Semantics(
            button: true,
            label: 'Open menu',
            child: InkResponse(
              onTap: () {},
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
  const _ReserveSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Search in AgriSell',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AgrisellColors.brandBlack.withValues(alpha: 0.58),
                fontSize: 13,
                height: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const HomeAssetIcon(
            asset: AgrisellAssets.iconSearch,
            size: 25,
            color: AgrisellColors.brandBlack,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
