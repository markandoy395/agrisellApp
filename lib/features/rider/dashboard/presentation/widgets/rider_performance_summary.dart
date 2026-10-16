import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_performance_summary_styles.dart';
import 'package:flutter/material.dart';
import '../styles/rider_home_design_styles.dart';
import '../styles/rider_reference_styles.dart';

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
      decoration: RiderHomeDesignStyles.card,
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
                  style: RiderPerformanceSummaryStyles.performanceSummaryText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty) ...[
            const Center(
              child: Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: AgrisellColors.mutedText,
              ),
            ),
            const Center(
              child: Text(
                'Performance data is not available yet.',
                style: RiderPerformanceSummaryStyles
                    .performanceDataIsNotAvailableText,
              ),
            ),
          ] else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns =
                    constraints.maxWidth < 300 ||
                        MediaQuery.textScalerOf(context).scale(12) > 16
                    ? 2
                    : rows.length;
                return Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: [
                    for (final row in rows)
                      SizedBox(
                        width:
                            (constraints.maxWidth - (columns - 1) * 8) /
                            columns,
                        child: _PerformanceChip(item: row),
                      ),
                  ],
                );
              },
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
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: item.icon == Icons.star_rate_rounded
                  ? AgrisellColors.accentOrange
                  : item.icon == Icons.cancel_outlined
                  ? RiderHomeDesignStyles.red
                  : AgrisellColors.authGreen,
              size: 18,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(item.value, style: RiderReferenceStyles.value),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          item.label,
          textAlign: TextAlign.center,
          style: RiderReferenceStyles.small,
        ),
      ],
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
