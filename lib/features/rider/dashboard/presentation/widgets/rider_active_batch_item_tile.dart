import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_active_batch_summary_styles.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';

class RiderActiveBatchItemTile extends StatelessWidget {
  const RiderActiveBatchItemTile({
    required this.delivery,
    required this.onTap,
    super.key,
  });

  final DeliveryRequest delivery;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: RiderActiveBatchSummaryStyles.itemMargin,
    child: InkWell(
      borderRadius: RiderActiveBatchSummaryStyles.itemBorderRadius,
      onTap: onTap,
      child: Padding(
        padding: RiderActiveBatchSummaryStyles.itemPadding,
        child: Row(
          children: [
            Icon(
              delivery.stage.isDeliveryLeg
                  ? Icons.location_on_outlined
                  : Icons.storefront_outlined,
              color: RiderActiveBatchSummaryStyles.itemIconColor,
              size: RiderActiveBatchSummaryStyles.itemIconSize,
            ),
            RiderActiveBatchSummaryStyles.spacingSmall,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${delivery.orderNumber} · ${delivery.productName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RiderActiveBatchSummaryStyles.itemTitleStyle,
                  ),
                  Text(
                    '${delivery.stage.isDeliveryLeg ? 'Delivery' : 'Pickup'} · '
                    '${riderDeliveryDeadlineLabel(delivery)}',
                    style: RiderActiveBatchSummaryStyles.itemSubtitleStyle,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: RiderActiveBatchSummaryStyles.itemTrailingIconColor,
            ),
          ],
        ),
      ),
    ),
  );
}

class RiderBatchDetail extends StatelessWidget {
  const RiderBatchDetail({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(
        icon,
        color: RiderActiveBatchSummaryStyles.detailIconColor,
        size: RiderActiveBatchSummaryStyles.detailIconSize,
      ),
      RiderActiveBatchSummaryStyles.spacingSmall,
      Expanded(
        child: Text(
          '$label: $value',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: RiderActiveBatchSummaryStyles.detailValueStyle,
        ),
      ),
    ],
  );
}

String riderDeliveryDeadlineLabel(DeliveryRequest request) {
  final value = request.stage.isDeliveryLeg
      ? request.deliveryDeadline ?? request.pickupDeadline
      : request.pickupDeadline;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute deadline';
}
