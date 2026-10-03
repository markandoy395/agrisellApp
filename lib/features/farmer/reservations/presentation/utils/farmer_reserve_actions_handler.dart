import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/farmer/reservations/data/farmer_rider_selection_repository.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/controllers/farmer_rider_assignment_controller.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/screens/farmer_rider_selection_screen.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_cancellation_dialog.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

abstract final class FarmerReserveActionsHandler {
  static bool matchesSearch(PlacedOrder order, String searchQuery) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return true;
    return order.id.toLowerCase().contains(query) ||
        order.buyerName.toLowerCase().contains(query) ||
        order.buyerId.toLowerCase().contains(query) ||
        order.deliveryAddress.toLowerCase().contains(query) ||
        order.phoneNumber.toLowerCase().contains(query) ||
        order.items.any(
          (item) =>
              item.productName.toLowerCase().contains(query) ||
              item.sellerName.toLowerCase().contains(query),
        );
  }

  static List<PlacedOrder> filterWorkflowOrders(
    List<PlacedOrder> orders,
    String searchQuery,
  ) {
    final workflowOrders = orders
        .where(
          (order) =>
              order.status != PlacedOrderStatus.delivered &&
              (order.status != PlacedOrderStatus.cancelled ||
                  order.payment.needsFarmerReview ||
                  order.payment.status == OrderPaymentStatus.refundRequired),
        )
        .toList(growable: false);
    return workflowOrders.where((o) => matchesSearch(o, searchQuery)).toList(
      growable: false,
    );
  }

  static Future<void> chooseRider({
    required BuildContext context,
    required PlacedOrder order,
    required FarmerRiderSelectionRepository repository,
    required FarmerRiderAssignmentController controller,
  }) async {
    final request = await Navigator.of(context).push<FarmerRiderRequest>(
      agrisellPageRoute(
        builder: (_) => FarmerRiderSelectionScreen(
          orderId: order.id,
          repository: repository,
        ),
      ),
    );
    if (request != null) controller.apply(request);
  }

  static Future<void> cancelRiderRequest({
    required BuildContext context,
    required FarmerRiderRequest request,
    required FarmerRiderAssignmentController controller,
    required bool Function() isMounted,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel rider request?'),
        content: Text(
          'Cancel the pending request sent to ${request.riderName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !isMounted()) return;
    try {
      await controller.cancel(request);
    } on Object catch (error) {
      if (!isMounted()) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'The request could not be cancelled.' : message,
          ),
        ),
      );
    }
  }

  static Future<void> cancelOrder({
    required BuildContext context,
    required PlacedOrder order,
    required OrderController orderController,
    required FarmerRiderAssignmentController riderController,
    required bool Function() isMounted,
  }) async {
    final reason = await showFarmerOrderCancellationDialog(context);
    if (reason == null || !isMounted()) return;
    try {
      await orderController.cancelFarmerOrder(order.id, reason);
      await riderController.refresh();
      if (!isMounted()) return;
      ScaffoldMessenger.of(context).showAppSnackBar(
        const SnackBar(content: Text('Order cancelled successfully.')),
      );
    } on Object catch (error) {
      if (!isMounted()) return;
      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceFirst('Bad state: ', '')
          .trim();
      ScaffoldMessenger.of(context).showAppSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty ? 'The order could not be cancelled.' : message,
          ),
        ),
      );
    }
  }
}
