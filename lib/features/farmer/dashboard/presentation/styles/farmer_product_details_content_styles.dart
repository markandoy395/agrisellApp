import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/styles/farmer_product_details_styles.dart';

abstract final class FarmerProductDetailsContentStyles {
  static TextStyle textStyle(Color nameColor) =>
      FarmerProductDetailsStyles.nameText.copyWith(color: nameColor);

  static TextStyle textSpanStyle(Color valueColor) =>
      FarmerProductDetailsStyles.priceText.copyWith(color: valueColor);

  static TextStyle textStyle2(FarmerDashboardProduct product) =>
      FarmerProductDetailsStyles.stockText.copyWith(
        color: product.isOutOfStock
            ? AgrisellColors.statusRedText
            : AgrisellColors.mutedText,
      );
}
