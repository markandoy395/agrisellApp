import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_status.dart';
import '../delivery_status_presentation.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_delivery_card_header.dart';
import 'rider_delivery_address_pair.dart';
import 'rider_delivery_compact_progress.dart';

class RiderActiveTripCard extends StatelessWidget {
  const RiderActiveTripCard({
    required this.request,
    required this.status,
    required this.onManage,
    this.onMap,
    super.key,
  });
  final DeliveryRequest request;
  final DeliveryStatus status;
  final VoidCallback? onManage;
  final VoidCallback? onMap;

  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderDeliveriesDesignStyles.card,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiderDeliveryCardHeader(request: request),
        const SizedBox(height: 14),
        RiderDeliveryAddressPair(request: request),
        const SizedBox(height: 18),
        RiderDeliveryCompactProgress(status: status),
        const SizedBox(height: 14),
        Container(
          decoration: RiderDeliveriesDesignStyles.inset,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.near_me, color: AgrisellColors.authGreen),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayLabel,
                      style: RiderDeliveriesDesignStyles.label,
                    ),
                    Text(
                      _deadline(context),
                      style: RiderDeliveriesDesignStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: onManage,
                style: RiderDeliveriesDesignStyles.primary,
                child: const Text('Manage delivery'),
              ),
            ),
            if (onMap != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMap,
                  style: RiderDeliveriesDesignStyles.secondary,
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Map'),
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );

  String _deadline(BuildContext context) {
    final pickedUp =
        status.isNormalFlow &&
        status.index >= DeliveryStatus.productPickedUp.index;
    final deadline = pickedUp
        ? request.deliveryDeadline
        : request.pickupDeadline;
    if (deadline == null) return 'Delivery deadline unavailable';
    final local = deadline.toLocal();
    final labels = MaterialLocalizations.of(context);
    final time = labels.formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '${pickedUp ? 'Delivery' : 'Pickup'} deadline: '
        '${labels.formatShortDate(local)} $time';
  }
}
