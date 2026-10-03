import 'package:flutter/material.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

class FarmerWorkflowAction {
  const FarmerWorkflowAction({
    required this.label,
    required this.icon,
    required this.successMessage,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final String successMessage;
  final Future<void> Function() onPressed;
}

abstract final class FarmerOrderWorkflowActionResolver {
  static FarmerWorkflowAction? actionFor({
    required PlacedOrder order,
    required OrderController controller,
    FarmerRiderRequest? riderRequest,
    Future<void> Function()? onChooseRider,
  }) {
    if (order.status == PlacedOrderStatus.readyForPickup &&
        riderRequest == null &&
        onChooseRider != null) {
      return FarmerWorkflowAction(
        label: 'Choose a rider',
        icon: Icons.delivery_dining_outlined,
        successMessage: '',
        onPressed: onChooseRider,
      );
    }
    return switch (order.status) {
      PlacedOrderStatus.toShip
          when order.payment.allowsOrderAcceptance &&
              !order.isAcceptanceOverdue =>
        FarmerWorkflowAction(
          label: 'Accept order',
          icon: Icons.verified_outlined,
          successMessage: 'Order accepted and the buyer was notified.',
          onPressed: () => controller.acceptOrder(order.id),
        ),
      PlacedOrderStatus.preparing => FarmerWorkflowAction(
        label: 'Mark ready for pickup',
        icon: Icons.inventory_2_outlined,
        successMessage: 'Order marked ready for rider pickup.',
        onPressed: () => controller.markReadyForPickup(order.id),
      ),
      _ => null,
    };
  }

  static Future<void> runAction(
    BuildContext context,
    FarmerWorkflowAction action,
  ) async {
    try {
      await action.onPressed();
      if (!context.mounted || action.successMessage.isEmpty) return;
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(SnackBar(content: Text(action.successMessage)));
    } on Object catch (error) {
      if (!context.mounted) return;
      final detail = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Bad state: ', '')
          .trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            detail.isEmpty
                ? 'The order update could not be saved. Try again.'
                : detail,
          ),
        ),
      );
    }
  }

  static Future<void> runCancellation(
    BuildContext context,
    Future<void> Function()? onCancelOrder,
  ) async {
    if (onCancelOrder == null) return;
    try {
      await onCancelOrder();
    } on Object catch (error) {
      if (!context.mounted) return;
      final detail = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            detail.isEmpty ? 'The order could not be cancelled.' : detail,
          ),
        ),
      );
    }
  }
}
