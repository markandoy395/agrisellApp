import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../../dashboard/domain/rider_history_models.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_delivery_request_details.dart';

class RiderDeliveryHistoryRow extends StatelessWidget {
  const RiderDeliveryHistoryRow({
    required this.entry,
    required this.onTap,
    this.imageUrl,
    super.key,
  });
  final RiderDeliveryHistoryEntry entry;
  final VoidCallback onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final completed = entry.status == RiderHistoryStatus.completed;
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(entry.completedAt.toLocal()));
    return Material(
      color: AgrisellColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Stack(
                children: [
                  RiderRequestProductImage(
                    url: imageUrl,
                    productName: entry.productName,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      completed ? Icons.check_circle : Icons.cancel,
                      color: completed
                          ? AgrisellColors.authGreen
                          : AgrisellColors.statusRedText,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.productName,
                      style: RiderDeliveriesDesignStyles.label,
                    ),
                    Text(
                      entry.orderNumber,
                      style: RiderDeliveriesDesignStyles.caption,
                    ),
                    Text(
                      '${entry.status.label} - $time',
                      style: RiderDeliveriesDesignStyles.caption,
                    ),
                    if (completed)
                      Text(
                        'PHP ${entry.deliveryFee.toStringAsFixed(2)}',
                        style: RiderDeliveriesDesignStyles.earning,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AgrisellColors.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

class RiderDeliveryHistoryFooter extends StatelessWidget {
  const RiderDeliveryHistoryFooter({
    required this.empty,
    required this.filtered,
    super.key,
  });
  final bool empty;
  final bool filtered;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
    child: Column(
      children: [
        const Icon(
          Icons.manage_search_rounded,
          size: 64,
          color: AgrisellColors.deliveryGray,
        ),
        const SizedBox(height: 12),
        Text(
          empty ? 'No delivery history' : 'No more delivery history',
          style: RiderDeliveriesDesignStyles.title,
        ),
        const SizedBox(height: 6),
        Text(
          filtered
              ? 'No more matching deliveries.'
              : 'Completed, cancelled, failed, returned, and disputed deliveries will appear here.',
          textAlign: TextAlign.center,
          style: RiderDeliveriesDesignStyles.caption,
        ),
      ],
    ),
  );
}
