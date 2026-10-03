import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';

/// Card showing the current active delivery on top of the rider map.
class RiderActiveDeliveryCard extends StatelessWidget {
  const RiderActiveDeliveryCard({
    required this.request,
    required this.onNavigate,
    super.key,
  });

  final DeliveryRequest request;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    final navLabel = request.stage.isDeliveryLeg
        ? 'Navigate to delivery'
        : 'Navigate to pickup';

    return LayoutBuilder(
      builder: (context, constraints) => Material(
        color: RiderMapStyles.activeCardBackground,
        elevation: RiderMapStyles.activeCardElevation,
        borderRadius: RiderMapStyles.activeCardRadius,
        child: Padding(
          padding: RiderMapStyles.activeCardPadding,
          child: Row(
            children: [
              const CircleAvatar(
                radius: RiderMapStyles.avatarRadius,
                backgroundColor: AgrisellColors.statusOrangeBackground,
                foregroundColor: AgrisellColors.statusOrangeText,
                child: Icon(
                  Icons.local_shipping_rounded,
                  size: RiderMapStyles.avatarIconSize,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ACTIVE DELIVERY',
                      style: RiderMapStyles.activeCardBadge,
                    ),
                    Text(
                      request.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: RiderMapStyles.activeCardProduct,
                    ),
                  ],
                ),
              ),
              if (constraints.maxWidth <
                  RiderMapStyles.activeCardCompactBreakpoint)
                IconButton.filled(
                  tooltip: navLabel,
                  onPressed: onNavigate,
                  icon: const Icon(Icons.navigation_rounded),
                )
              else
                FilledButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(
                    Icons.navigation_rounded,
                    size: RiderMapStyles.actionIconSize,
                  ),
                  label: Text(navLabel),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
