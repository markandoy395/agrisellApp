import 'package:flutter/material.dart';
import 'package:agresell_app/features/buyer/home/presentation/styles/farmer_product_card_styles.dart';

abstract final class FarmerProductCardDetailsStyles {
  static TextStyle textStyle(Color textColor) =>
      FarmerProductCardStyles.nameText.copyWith(color: textColor);

  static TextStyle textSpanStyle(Color valueColor) =>
      FarmerProductCardStyles.priceText.copyWith(color: valueColor);

  static TextStyle valueText(Color color) =>
      FarmerProductCardStyles.metaText.copyWith(color: color);
}
