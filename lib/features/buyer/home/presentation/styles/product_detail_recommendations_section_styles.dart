import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class ProductDetailRecommendationsSectionStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );
}
