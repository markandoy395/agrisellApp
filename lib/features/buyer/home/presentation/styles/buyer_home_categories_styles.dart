import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BuyerHomeCategoriesStyles {
  static BoxDecoration animatedContainerDecoration(
    bool isShowAll,
    bool selected,
  ) => BoxDecoration(
    color: isShowAll
        ? AgrisellColors.authGreen
        : selected
        ? AgrisellColors.forestSoft
        : AgrisellColors.surface,
    shape: BoxShape.circle,
    border: Border.all(
      color: selected ? AgrisellColors.authGreen : AgrisellColors.borderLine,
      width: selected ? 2 : 1,
    ),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.07),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static TextStyle labelText(bool selected, bool isShowAll) => TextStyle(
    color: selected || isShowAll
        ? AgrisellColors.authGreen
        : AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.05,
    fontWeight: selected || isShowAll ? FontWeight.w700 : FontWeight.w500,
  );
}
