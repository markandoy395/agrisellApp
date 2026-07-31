import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderHistoryEntryCard extends StatelessWidget {
  const RiderHistoryEntryCard({required this.entry, this.onTap, super.key});

  final RiderDeliveryHistoryEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${entry.status.label} delivery ${entry.orderNumber}',
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: RiderSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _HistoryStatusPill(status: entry.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${entry.orderNumber} · ${formatRiderDateTime(entry.completedAt)}',
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (entry.quantityDescription.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.quantityDescription,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 10),
            _LocationLine(
              icon: Icons.storefront_outlined,
              value: entry.pickupAddress,
            ),
            const SizedBox(height: 6),
            _LocationLine(
              icon: Icons.location_on_outlined,
              value: entry.deliveryAddress,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  formatRiderCurrency(entry.deliveryFee),
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (entry.hasProof) ...[
                  const Icon(
                    Icons.verified_outlined,
                    color: AgrisellColors.authGreen,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                ],
                if (entry.customerRating case final rating?) ...[
                  const Icon(
                    Icons.star_rounded,
                    color: AgrisellColors.accentOrange,
                    size: 17,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _LocationLine extends StatelessWidget {
  const _LocationLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AgrisellColors.authGreen),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}

class _HistoryStatusPill extends StatelessWidget {
  const _HistoryStatusPill({required this.status});

  final RiderHistoryStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      RiderHistoryStatus.completed => AgrisellColors.statusGreenText,
      RiderHistoryStatus.cancelled => AgrisellColors.statusOrangeText,
      RiderHistoryStatus.failed => AgrisellColors.statusRedText,
      RiderHistoryStatus.returned => AgrisellColors.statusOrangeText,
      RiderHistoryStatus.disputed => AgrisellColors.statusRedText,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
