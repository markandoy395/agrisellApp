import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class EmptyCheckoutStateStyles {
  static final decoratedBoxDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(8),
  );

  static const noSelectedItemsForCheckoutText = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}
