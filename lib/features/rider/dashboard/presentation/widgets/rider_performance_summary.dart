import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderPerformanceSummary extends StatelessWidget {
  const RiderPerformanceSummary({
    required this.profile,
    required this.metrics,
    super.key,
  });

  final RiderProfile? profile;
  final RiderDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final rating = metrics.averageRating ?? profile?.rating;
    final completed =
        metrics.completedDeliveryCount ?? profile?.totalDeliveries;
    final rows = <_PerformanceItem>[
      if (rating != null && (rating > 0 || (completed ?? 0) > 0))
        _PerformanceItem(
          label: 'Average rating',
          value: rating.toStringAsFixed(1),
          icon: Icons.star_rate_rounded,
        ),
      if (completed != null)
        _PerformanceItem(
          label: 'Completed deliveries',
          value: '$completed',
          icon: Icons.check_circle_outline_rounded,
        ),
      if (metrics.onTimeDeliveryRate != null)
        _PerformanceItem(
          label: 'On-time rate',
          value: '${metrics.onTimeDeliveryRate!.toStringAsFixed(1)}%',
          icon: Icons.schedule_rounded,
        ),
      if (metrics.cancellationRate != null)
        _PerformanceItem(
          label: 'Cancellation rate',
          value: '${metrics.cancellationRate!.toStringAsFixed(1)}%',
          icon: Icons.cancel_outlined,
        ),
    ];
    return RiderSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.workspace_premium_outlined,
                color: AgrisellColors.authGreen,
                size: 22,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Performance summary',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            const Text(
              'Performance data is not available yet.',
              style: TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final row in rows) _PerformanceChip(item: row)],
            ),
        ],
      ),
    );
  }
}

class _PerformanceChip extends StatelessWidget {
  const _PerformanceChip({required this.item});

  final _PerformanceItem item;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${item.label}: ${item.value}',
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AgrisellColors.pageBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.icon, color: AgrisellColors.authGreen, size: 16),
          const SizedBox(width: 6),
          Text(
            '${item.label}: ${item.value}',
            style: const TextStyle(
              color: AgrisellColors.headingGreen,
              fontSize: 12,
              height: 1.1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PerformanceItem {
  const _PerformanceItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
