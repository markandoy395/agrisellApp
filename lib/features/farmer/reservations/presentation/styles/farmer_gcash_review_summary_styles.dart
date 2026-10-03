import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

abstract final class FarmerGcashReviewSummaryStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(11),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static TextStyle textStyle2(PlacedOrder order) => TextStyle(
    color: order.payment.hasReceiptImage
        ? AgrisellColors.statusGreenText
        : AgrisellColors.statusOrangeText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const textStyle3 = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w900,
  );
}
