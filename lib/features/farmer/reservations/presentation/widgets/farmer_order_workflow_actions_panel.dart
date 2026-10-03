import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_workflow_card_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/utils/farmer_order_workflow_action_resolver.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_guidance.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/presentation/widgets/delivery_tracking_sheet.dart';

class FarmerOrderWorkflowActionsPanel extends StatelessWidget {
  const FarmerOrderWorkflowActionsPanel({
    required this.order,
    required this.action,
    this.riderRequest,
    this.onChooseRider,
    this.onCancelRiderRequest,
    this.isCancellingRiderRequest = false,
    this.onCancelOrder,
    super.key,
  });

  final PlacedOrder order;
  final FarmerWorkflowAction? action;
  final FarmerRiderRequest? riderRequest;
  final Future<void> Function()? onChooseRider;
  final Future<void> Function(FarmerRiderRequest request)? onCancelRiderRequest;
  final bool isCancellingRiderRequest;
  final Future<void> Function()? onCancelOrder;

  @override
  Widget build(BuildContext context) {
    final showTracking =
        order.status == PlacedOrderStatus.shipping ||
        order.status == PlacedOrderStatus.readyForPickup ||
        order.status == PlacedOrderStatus.delivered ||
        riderRequest != null;
    final showCancellation =
        order.status.canFarmerCancel && onCancelOrder != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (action != null)
          SizedBox(
            width: double.infinity,
            height: FarmerOrderWorkflowCardStyles.primaryButtonHeight,
            child: FilledButton.icon(
              onPressed: () =>
                  FarmerOrderWorkflowActionResolver.runAction(context, action!),
              style: FarmerOrderWorkflowCardStyles.actionButtonStyle,
              icon: Icon(action!.icon, size: 16),
              label: Text(action!.label),
            ),
          )
        else if (order.status != PlacedOrderStatus.delivered)
          FarmerOrderWorkflowGuidance(
            order: order,
            riderRequest: riderRequest,
            onChooseAnotherRider: onChooseRider,
            onCancelRiderRequest: onCancelRiderRequest,
            isCancellingRiderRequest: isCancellingRiderRequest,
          ),
        if (showTracking) ...[
          FarmerOrderWorkflowCardStyles.spacingLarge,
          SizedBox(
            width: double.infinity,
            height: FarmerOrderWorkflowCardStyles.secondaryButtonHeight,
            child: OutlinedButton.icon(
              key: const ValueKey('farmer-track-rider-button'),
              onPressed: () => showDeliveryTrackingSheet(context, order: order),
              style: FarmerOrderWorkflowCardStyles.trackingButtonStyle,
              icon: const Icon(Icons.map_rounded, size: 16),
              label: const Text('Live Map & Rider Tracking'),
            ),
          ),
        ],
        if (showCancellation) ...[
          FarmerOrderWorkflowCardStyles.spacingLarge,
          SizedBox(
            width: double.infinity,
            height: FarmerOrderWorkflowCardStyles.secondaryButtonHeight,
            child: OutlinedButton.icon(
              key: const ValueKey('farmer-cancel-order-button'),
              onPressed: () =>
                  FarmerOrderWorkflowActionResolver.runCancellation(
                    context,
                    onCancelOrder,
                  ),
              style: FarmerOrderWorkflowCardStyles.cancelButtonStyle,
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Cancel Order'),
            ),
          ),
        ],
      ],
    );
  }
}
