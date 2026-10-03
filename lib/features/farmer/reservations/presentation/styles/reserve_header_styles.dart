import 'package:flutter/material.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/navigation/home_asset_icon.dart';

abstract final class ReserveHeaderStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(22)),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.16),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(30),
  );

  static const textStyle = TextStyle(
    fontSize: 13,
    color: AgrisellColors.brandBlack,
  );

  static InputDecoration inputDecoration(
    TextEditingController controller,
    void Function(String) onChanged,
  ) => InputDecoration(
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
  );
}
