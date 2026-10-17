import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/theme/app_typography.dart';

abstract final class BuyerCatalogStyles {
  static const background = AgrisellColors.authBackground;
  static const radius = BorderRadius.all(Radius.circular(14));
  static const imageRadius = BorderRadius.all(Radius.circular(10));
  static const imageFill = AgrisellColors.searchBackground;
  static final title = AppTypography.title.copyWith(
    color: AgrisellColors.headingGreen,
    fontSize: 17,
  );
  static final name = AppTypography.caption.copyWith(
    color: AgrisellColors.headingGreen,
    fontWeight: FontWeight.w700,
  );
  static final price = name.copyWith(color: AgrisellColors.authGreen);
  static final caption = AppTypography.caption.copyWith(
    color: AgrisellColors.mutedText,
  );
  static final stock = caption.copyWith(fontSize: 10);
  static final originalPrice = stock.copyWith(
    color: AgrisellColors.statusRedText,
    decoration: TextDecoration.lineThrough,
  );
  static final discountText = stock.copyWith(
    color: AgrisellColors.surface,
    fontWeight: FontWeight.w700,
  );
  static final discount = BoxDecoration(
    color: AgrisellColors.unavailableRed,
    borderRadius: BorderRadius.circular(12),
  );
  static final cartButton = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    disabledBackgroundColor: AgrisellColors.borderLine,
    minimumSize: const Size(36, 36),
    maximumSize: const Size(36, 36),
    padding: const EdgeInsets.all(9),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );
  static final textButton = TextButton.styleFrom(
    foregroundColor: AgrisellColors.authGreen,
    textStyle: AppTypography.caption,
  );
  static final appBar = AppBarTheme(
    backgroundColor: background,
    foregroundColor: AgrisellColors.headingGreen,
    surfaceTintColor: background,
    titleTextStyle: title,
    elevation: 0,
    centerTitle: false,
  );
  static InputDecoration get search => const InputDecoration(
    hintText: 'Search products',
    prefixIcon: Icon(Icons.search),
  );
  static final filtersShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(22),
  );
  static const columns = 2;
  static double cardHeight(double width, double scale, {bool sale = false}) =>
      width + (sale ? 100 : 88) + (scale - 1).clamp(0, 2) * 80;
  static BoxDecoration category(bool selected) => BoxDecoration(
    color: selected ? AgrisellColors.authGreen : AgrisellColors.surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: selected ? AgrisellColors.authGreen : AgrisellColors.borderLine,
    ),
  );
  static TextStyle categoryText(bool selected) => caption.copyWith(
    color: selected ? AgrisellColors.surface : AgrisellColors.headingGreen,
    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
    fontSize: 11,
  );
}
