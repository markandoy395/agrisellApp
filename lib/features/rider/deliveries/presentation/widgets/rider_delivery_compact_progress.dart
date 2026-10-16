import 'package:flutter/material.dart';
import '../styles/rider_map_progress_styles.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_status.dart';
import '../delivery_status_presentation.dart';
import '../styles/rider_deliveries_design_styles.dart';

class RiderDeliveryCompactProgress extends StatelessWidget {
  const RiderDeliveryCompactProgress({required this.status, super.key});
  final DeliveryStatus status;

  static const _steps = [
    DeliveryStatus.accepted,
    DeliveryStatus.goingToPickup,
    DeliveryStatus.productPickedUp,
    DeliveryStatus.goingToBuyer,
    DeliveryStatus.deliveryCompleted,
  ];
  static const _icons = [
    Icons.check_rounded,
    Icons.local_shipping_rounded,
    Icons.storefront_outlined,
    Icons.inventory_2_outlined,
    Icons.person_outline_rounded,
  ];
  static const _labels = [
    'Accepted',
    'Going to Pickup',
    'Arrived',
    'Picked Up',
    'To Buyer',
  ];

  @override
  Widget build(BuildContext context) {
    if (!status.isNormalFlow) {
      return Text(
        status.displayLabel,
        style: RiderDeliveriesDesignStyles.label,
      );
    }
    return Semantics(
      label: 'Delivery progress: ${status.displayLabel}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < _steps.length; index++) ...[
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: RiderMapProgressStyles.milestone(
                      status.index >= _steps[index].index,
                    ),
                    child: Center(
                      child: Icon(
                        _icons[index],
                        size: 15,
                        color: status.index >= _steps[index].index
                            ? AgrisellColors.surface
                            : AgrisellColors.deliveryGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _labels[index],
                    textAlign: TextAlign.center,
                    style: RiderMapProgressStyles.label(
                      status.index >= _steps[index].index,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
