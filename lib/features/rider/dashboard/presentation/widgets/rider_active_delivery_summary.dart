import 'package:flutter/material.dart';
import '../styles/rider_home_design_styles.dart';
import '../styles/rider_reference_styles.dart';

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
      decoration: RiderHomeDesignStyles.card,
      padding: RiderActiveDeliverySummaryStyles.activeCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping_rounded,
                size: 18,
                color: RiderHomeDesignStyles.green,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your next move',
                  style: RiderHomeDesignStyles.title,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: RiderReferenceStyles.progressBadge,
                child: const Text(
                  'In progress',
                  style: RiderReferenceStyles.progressText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RiderDeliveryProductImage(path: active.productImageUrl),
              RiderActiveDeliverySummaryStyles.spacingImage,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      active.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RiderActiveDeliverySummaryStyles.productNameStyle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      active.orderNumber,
                      style: RiderActiveDeliverySummaryStyles.orderNumberStyle,
                    ),
                    RiderActiveDeliverySummaryStyles.spacingTitlePills,
                    Wrap(
                      spacing: RiderActiveDeliverySummaryStyles.pillSpacing,
                      runSpacing: RiderActiveDeliverySummaryStyles.pillSpacing,
                      children: [
                        RiderStatusPill(
                          label: active.stage.label,
                          icon: Icons.route_outlined,
                          backgroundColor: AgrisellColors.statusGreenBackground,
                          foregroundColor: AgrisellColors.statusGreenText,
                        ),
                        if (active.deliveryFee > 0)
                          Text(
                            'PHP ${active.deliveryFee.toStringAsFixed(2)}',
                            style: RiderReferenceStyles.fee,
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
            decoration: RiderReferenceStyles.nextMove,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next: ${RiderActiveDeliveryFormatters.nextAction(active.stage)}',
                  style: RiderActiveDeliverySummaryStyles.nextActionTitleStyle,
                ),
                RiderActiveDeliverySummaryStyles.spacingNextActionTexts,
                Text(
                  'Pickup deadline: ${RiderActiveDeliveryFormatters.deadline(active.pickupDeadline)}',
                  style:
                      RiderActiveDeliverySummaryStyles.nextActionDeadlineStyle,
                ),
              ],
            ),
          ),
          RiderActiveDeliverySummaryStyles.spacingSection,
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: RiderHomeDesignStyles.primaryButton,
                  onPressed: onContinue,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  iconAlignment: IconAlignment.end,
                  label: const Text('Continue delivery'),
                ),
              ),
              if (RiderActiveDeliveryFormatters.canOpenMap(active)) ...[
                RiderActiveDeliverySummaryStyles.spacingActions,
                OutlinedButton.icon(
                  style: RiderHomeDesignStyles.secondaryButton,
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
