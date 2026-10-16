import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_delivery_request_details.dart';
import 'rider_request_priority.dart';
import '../../../presentation/widgets/rider_status_pills.dart';

class RiderDeliveryCardHeader extends StatelessWidget {
  const RiderDeliveryCardHeader({
    required this.request,
    this.showPriority = false,
    this.pickupDistanceKm,
    this.pickupTravelMinutes,
    super.key,
  });
  final DeliveryRequest request;
  final bool showPriority;
  final double? pickupDistanceKm;
  final int? pickupTravelMinutes;

  @override
  Widget build(BuildContext context) {
    final priority = riderRequestPriorityStyle(request.priority);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiderRequestProductImage(
          url: request.productImageUrl,
          productName: request.productName,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showPriority) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RiderStatusPill(
                      label: priority.label,
                      backgroundColor: priority.background,
                      foregroundColor: priority.foreground,
                    ),
                    if (pickupDistanceKm != null)
                      Text(
                        '${pickupDistanceKm!.toStringAsFixed(1)} km to pickup',
                        style: RiderDeliveriesDesignStyles.distance,
                      ),
                    if (pickupTravelMinutes != null)
                      Text(
                        '$pickupTravelMinutes min',
                        style: RiderDeliveriesDesignStyles.caption,
                      ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              Text(
                request.productName,
                style: RiderDeliveriesDesignStyles.title,
              ),
              Text(
                request.orderNumber.toLowerCase().startsWith('order ')
                    ? request.orderNumber
                    : 'Order ${request.orderNumber}',
                style: RiderDeliveriesDesignStyles.caption,
              ),
              Text(
                'Seller: ${request.sellerName}',
                style: RiderDeliveriesDesignStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
