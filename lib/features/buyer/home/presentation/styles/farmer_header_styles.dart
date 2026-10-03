import 'package:flutter/material.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer/farmer_text_styles.dart';

abstract final class FarmerHeaderStyles {
  static const containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
  );

  static const findLocalFarmersText = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const browseHarvestsAndConnectDirectlyText = TextStyle(
    color: AgrisellColors.forestSoft,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(24),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static InputDecoration inputDecoration(
    BuildContext context,
    TextEditingController controller,
    void Function() onClear,
  ) => InputDecoration(
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
  );
}
