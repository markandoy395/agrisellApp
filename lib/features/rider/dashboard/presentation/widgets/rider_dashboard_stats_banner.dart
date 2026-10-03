import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_state_banner_styles.dart';

class RiderDashboardStatsBanner extends StatelessWidget {
  const RiderDashboardStatsBanner({required this.metrics, super.key});

  final RiderDashboardMetrics metrics;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: RiderDashboardStateBannerStyles.statsBannerDecoration,
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: AgrisellColors.authGreen,
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Dashboard stats',
                  style: RiderDashboardStateBannerStyles.statsTitleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              RiderStatsChip(
                label: 'Completed',
                value: '${metrics.todayCompletedDeliveries}',
              ),
              RiderStatsChip(
                label: 'Earnings',
                value:
                    'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}',
              ),
              RiderStatsChip(
                label: 'Messages',
                value: '${metrics.unreadMessageCount}',
              ),
              RiderStatsChip(
                label: 'Alerts',
                value: '${metrics.unreadNotificationCount}',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class RiderStatsChip extends StatelessWidget {
  const RiderStatsChip({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    constraints: RiderDashboardStateBannerStyles.statsChipConstraints,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: RiderDashboardStateBannerStyles.statsChipDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: RiderDashboardStateBannerStyles.statsValueStyle,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: RiderDashboardStateBannerStyles.statsLabelStyle,
        ),
      ],
    ),
  );
}
