import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_history_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderEarningsHistory extends StatelessWidget {
  const RiderEarningsHistory({
    required this.entries,
    required this.onOpenDelivery,
    super.key,
  });

  final List<RiderEarningEntry> entries;
  final ValueChanged<String> onOpenDelivery;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const RiderSectionTitle(title: 'Earnings history'),
      const SizedBox(height: 8),
      for (final entry in entries) ...[
        InkWell(
          onTap: entry.deliveryId == null
              ? null
              : () => onOpenDelivery(entry.deliveryId!),
          borderRadius: BorderRadius.circular(14),
          child: RiderSurfaceCard(
            child: Row(
              children: [
                _EntryIcon(type: entry.type),
                const SizedBox(width: 10),
                Expanded(child: _EntryDetails(entry: entry)),
                const SizedBox(width: 8),
                Text(
                  formatRiderCurrency(entry.netAmount),
                  style: RiderEarningsHistoryStyles.textStyle(entry),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ],
  );
}

class _EntryDetails extends StatelessWidget {
  const _EntryDetails({required this.entry});
  final RiderEarningEntry entry;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        entry.description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: SharedPresentationStyles.headingBodyExtraBold,
      ),
      const SizedBox(height: 3),
      Text(
        '${entry.type.label} • ${entry.payoutStatus.label}'
        '${entry.orderNumber == null ? '' : ' • ${entry.orderNumber}'}',
        style: SharedPresentationStyles.mutedCaptionSemibold,
      ),
      if (entry.estimatedEarning != null) ...[
        const SizedBox(height: 3),
        Text(
          'Estimated ${formatRiderCurrency(entry.estimatedEarning!)} • '
          'Final ${formatRiderCurrency(entry.netAmount)}',
          style: SharedPresentationStyles.mutedCaption,
        ),
      ],
    ],
  );
}

class _EntryIcon extends StatelessWidget {
  const _EntryIcon({required this.type});
  final RiderEarningType type;

  @override
  Widget build(BuildContext context) {
    final negative =
        type == RiderEarningType.deduction || type == RiderEarningType.penalty;
    final color = negative
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;
    return DecoratedBox(
      decoration: RiderEarningsHistoryStyles.decoratedBoxDecoration(color),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Icon(
          negative
              ? Icons.remove_circle_outline_rounded
              : Icons.add_circle_outline_rounded,
          size: 18,
          color: color,
        ),
      ),
    );
  }
}
