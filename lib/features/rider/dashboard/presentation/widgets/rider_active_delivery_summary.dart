import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';
import '../styles/rider_active_delivery_summary_styles.dart';
import '../utils/rider_active_delivery_formatters.dart';
import 'rider_delivery_product_image.dart';
import 'rider_delivery_route_stop.dart';
import 'rider_no_active_delivery_card.dart';

class RiderActiveDeliverySummary extends StatelessWidget {
  const RiderActiveDeliverySummary({
    required this.delivery,
    required this.onContinue,
    required this.onOpenMap,
    super.key,
  });

  final DeliveryRequest? delivery;
  final VoidCallback onContinue, onOpenMap;

  @override
  Widget build(BuildContext context) {
    final active = delivery;
    if (active == null) {
      return RiderNoActiveDeliveryCard(onContinue: onContinue);
    }
    return RiderSurfaceCard(
      padding: RiderActiveDeliverySummaryStyles.activeCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiderDeliveryProductImage(path: active.productImageUrl),
              RiderActiveDeliverySummaryStyles.spacingImage,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            active.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: RiderActiveDeliverySummaryStyles
                                .productNameStyle,
                          ),
                        ),
                        RiderActiveDeliverySummaryStyles.spacingTitleOrder,
                        Text(
                          active.orderNumber,
                          style: RiderActiveDeliverySummaryStyles
                              .orderNumberStyle,
                        ),
                      ],
                    ),
                    RiderActiveDeliverySummaryStyles.spacingTitlePills,
                    Wrap(
                      spacing: RiderActiveDeliverySummaryStyles.pillSpacing,
                      runSpacing: RiderActiveDeliverySummaryStyles.pillSpacing,
                      children: [
                        RiderStatusPill(
                          label: active.stage.label,
                          icon: Icons.route_outlined,
                          backgroundColor:
                              AgrisellColors.statusGreenBackground,
                          foregroundColor: AgrisellColors.statusGreenText,
                        ),
                        if (active.deliveryFee > 0)
                          RiderStatusPill(
                            label:
                                'PHP ${active.deliveryFee.toStringAsFixed(2)}',
                            icon: Icons.payments_outlined,
                            backgroundColor:
                                AgrisellColors.statusBlueBackground,
                            foregroundColor: AgrisellColors.statusBlueText,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          RiderActiveDeliverySummaryStyles.spacingSection,
          RiderDeliveryRouteStop(
            icon: Icons.storefront_outlined,
            label: 'Pickup',
            value: active.pickupLocation.address,
          ),
          RiderActiveDeliverySummaryStyles.spacingStops,
          RiderDeliveryRouteStop(
            icon: Icons.location_on_outlined,
            label: 'Drop-off',
            value: active.deliveryLocation.address,
          ),
          RiderActiveDeliverySummaryStyles.spacingNextAction,
          Container(
            width: double.infinity,
            padding: RiderActiveDeliverySummaryStyles.nextActionPadding,
            decoration:
                RiderActiveDeliverySummaryStyles.nextActionBoxDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next: ${RiderActiveDeliveryFormatters.nextAction(active.stage)}',
                  style:
                      RiderActiveDeliverySummaryStyles.nextActionTitleStyle,
                ),
                RiderActiveDeliverySummaryStyles.spacingNextActionTexts,
                Text(
                  'Pickup deadline: ${RiderActiveDeliveryFormatters.deadline(active.pickupDeadline)}',
                  style: RiderActiveDeliverySummaryStyles
                      .nextActionDeadlineStyle,
                ),
              ],
            ),
          ),
          RiderActiveDeliverySummaryStyles.spacingSection,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Continue delivery'),
                ),
              ),
              if (RiderActiveDeliveryFormatters.canOpenMap(active)) ...[
                RiderActiveDeliverySummaryStyles.spacingActions,
                OutlinedButton.icon(
                  onPressed: onOpenMap,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Map'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
