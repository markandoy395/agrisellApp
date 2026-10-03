import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BasketScreenStatesStyles {
  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(14),
  );

  static const confirmDeliveryAndPaymentAtText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
}
