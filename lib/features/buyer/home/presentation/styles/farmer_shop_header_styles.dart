import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class FarmerShopHeaderStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.22),
  );

  static final containerDecoration = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
    shape: BoxShape.circle,
  );

  static final decoratedBoxDecoration2 = BoxDecoration(
    color: AgrisellColors.brandBlack.withValues(alpha: 0.42),
    borderRadius: BorderRadius.circular(22),
  );

  static const textStyle = TextStyle(
    color: AgrisellColors.surface,
    fontSize: 12,
    height: 1.1,
  );

  static final inputDecoration = InputDecoration(
    hintText: 'Search in shop',
    hintStyle: TextStyle(
      color: AgrisellColors.surface.withValues(alpha: 0.72),
      fontSize: 12,
      height: 1.1,
    ),
    border: InputBorder.none,
    isDense: true,
    contentPadding: const EdgeInsets.fromLTRB(14, 10, 6, 8),
    suffixIconConstraints: const BoxConstraints.tightFor(width: 38, height: 38),
    suffixIcon: Icon(
      Icons.search_rounded,
      color: AgrisellColors.surface.withValues(alpha: 0.9),
      size: 19,
    ),
  );
}
