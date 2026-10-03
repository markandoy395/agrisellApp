import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderDeliveryRequestDetailsStyles {
  static const textText = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(8),
  );
}
