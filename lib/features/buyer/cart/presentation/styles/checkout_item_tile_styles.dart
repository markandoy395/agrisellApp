import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class CheckoutItemTileStyles {
  static const textStyle = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static const textStyle2 = TextStyle(
    color: AgrisellColors.brandBlack,
    fontSize: 15,
    height: 1.1,
    fontWeight: FontWeight.w800,
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(7),
  );

  static const textStyle3 = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w700,
  );

  static final containerDecoration2 = BoxDecoration(
    color: AgrisellColors.limeSoft,
    borderRadius: BorderRadius.circular(6),
  );

  static const textStyle4 = TextStyle(
    color: AgrisellColors.forestDark,
    fontSize: 12,
    height: 1,
    fontWeight: FontWeight.w800,
  );
}
