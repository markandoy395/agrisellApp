import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

abstract final class BasketItemStyles {
  static BoxDecoration animatedContainerDecoration(BasketCartItem item) =>
      BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isSelected
              ? AgrisellColors.authGreen.withValues(alpha: 0.5)
              : AgrisellColors.borderLine,
          width: item.isSelected ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );
}
