import 'package:flutter/material.dart';

import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_checkout_controls.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/notched_checkout_footer.dart';

class BasketCheckoutBar extends StatelessWidget {
  const BasketCheckoutBar({required this.controller, super.key});

  static const barHeight = NotchedCheckoutFooter.barHeight;

  final BasketController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return NotchedCheckoutFooter(
          actionLabel: 'Checkout',
          enabled: controller.selectedQuantity > 0,
          onActionTap: () {
            Navigator.of(context).pushNamed(AgrisellRoutes.checkout);
          },
          leading: BasketCheckoutSummary(
            allSelected: controller.allSelected,
            hasItems: controller.hasItems,
            selectedQuantity: controller.selectedQuantity,
            total: controller.selectedTotal,
            onAllChanged: controller.setAllSelected,
          ),
        );
      },
    );
  }
}
