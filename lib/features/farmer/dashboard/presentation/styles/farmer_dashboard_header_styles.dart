import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerDashboardHeaderStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.13),
        blurRadius: 14,
        offset: const Offset(0, 6),
      ),
    ],
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static InputDecoration inputDecoration(
    TextEditingController controller,
    void Function(String) onChanged,
  ) => InputDecoration(
    hintText: 'Search products',
    hintStyle: TextStyle(
      color: AgrisellColors.brandBlack.withValues(alpha: 0.55),
      fontSize: 12,
    ),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(vertical: 11),
    prefixIcon: const Icon(Icons.search_rounded, size: 21),
    suffixIcon: controller.text.isEmpty
        ? null
        : IconButton(
            tooltip: 'Clear search',
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(Icons.close_rounded, size: 19),
          ),
  );
}
