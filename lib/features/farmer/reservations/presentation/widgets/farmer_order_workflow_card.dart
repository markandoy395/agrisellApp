import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_workflow_card_styles.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/utils/farmer_order_workflow_action_resolver.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_payment_panel.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_actions_panel.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_order_workflow_status.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_waiting_panel.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/widgets/order_acceptance_deadline_card.dart';

class FarmerOrderWorkflowCard extends StatelessWidget {
  const FarmerOrderWorkflowCard({
    required this.order,
    required this.controller,
    this.riderRequest,
    this.onChooseRider,
    this.onCancelRiderRequest,
    this.isCancellingRiderRequest = false,
    this.onCancelOrder,
    super.key,
  });

  final PlacedOrder order;
  final OrderController controller;
  final FarmerRiderRequest? riderRequest;
  final Future<void> Function()? onChooseRider;
  final Future<void> Function(FarmerRiderRequest request)? onCancelRiderRequest;
  final bool isCancellingRiderRequest;
  final Future<void> Function()? onCancelOrder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final action = FarmerOrderWorkflowActionResolver.actionFor(
      order: order,
      controller: controller,
      riderRequest: riderRequest,
      onChooseRider: onChooseRider,
    );

    return DecoratedBox(
      decoration: FarmerOrderWorkflowCardStyles.cardDecoration,
      child: Padding(
        padding: FarmerOrderWorkflowCardStyles.cardPadding(width),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    order.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FarmerOrderWorkflowCardStyles.orderIdStyle,
                  ),
                ),
                FarmerOrderWorkflowStatus(
                  status: order.status,
                  isExpired: order.isExpired,
                ),
              ],
            ),
            FarmerOrderWorkflowCardStyles.spacingMedium,
            OrderAcceptanceDeadlineCard(
              order: order,
              audience: OrderDeadlineAudience.farmer,
            ),
            if (order.acceptanceExpiresAt != null &&
                (order.isExpired || order.status == PlacedOrderStatus.toShip))
              FarmerOrderWorkflowCardStyles.spacingMedium,
            const Divider(
              height: 1,
              color: FarmerOrderWorkflowCardStyles.dividerColor,
            ),
            FarmerOrderWorkflowCardStyles.spacingSmall,
            for (final item in order.items)
              Padding(
                padding: FarmerOrderWorkflowCardStyles.itemPadding,
                child: Text(
                  '${item.productName}  •  ${item.quantity} ${item.unit}',
                  style: FarmerOrderWorkflowCardStyles.itemTextStyle,
                ),
              ),
            FarmerOrderWorkflowCardStyles.spacingMedium,
            FarmerOrderPaymentPanel(order: order),
            FarmerOrderWorkflowCardStyles.spacingLarge,
            if (order.status == PlacedOrderStatus.readyForPickup &&
                riderRequest == null) ...[
              const FarmerRiderWaitingPanel(),
              FarmerOrderWorkflowCardStyles.spacingLarge,
            ],
            FarmerOrderWorkflowActionsPanel(
              order: order,
              action: action,
              riderRequest: riderRequest,
              onChooseRider: onChooseRider,
              onCancelRiderRequest: onCancelRiderRequest,
              isCancellingRiderRequest: isCancellingRiderRequest,
              onCancelOrder: onCancelOrder,
            ),
          ],
        ),
      ),
    );
  }
}
