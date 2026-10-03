import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_no_active_delivery_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import '../styles/rider_active_delivery_summary_styles.dart';

class RiderNoActiveDeliveryCard extends StatelessWidget {
  const RiderNoActiveDeliveryCard({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return RiderSurfaceCard(
      padding: RiderActiveDeliverySummaryStyles.emptyCardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: RiderActiveDeliverySummaryStyles.iconBadgeSize,
                height: RiderActiveDeliverySummaryStyles.iconBadgeSize,
                alignment: Alignment.center,
                decoration: RiderNoActiveDeliveryCardStyles.containerDecoration,
                child: const Icon(
                  Icons.route_outlined,
                  color: RiderActiveDeliverySummaryStyles.emptyBadgeForeground,
                  size: RiderActiveDeliverySummaryStyles.iconBadgeIconSize,
                ),
              ),
              RiderActiveDeliverySummaryStyles.spacingIconBadge,
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No active delivery',
                      style: RiderActiveDeliverySummaryStyles.emptyTitleStyle,
                    ),
                    RiderActiveDeliverySummaryStyles.spacingTitleSubtitle,
                    Text(
                      'Accepted jobs and route progress will appear here.',
                      style:
                          RiderActiveDeliverySummaryStyles.emptySubtitleStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          RiderActiveDeliverySummaryStyles.spacingEmptyAction,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onContinue,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Browse delivery requests'),
            ),
          ),
        ],
      ),
    );
  }
}
