import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
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
    final rows = <String>[
      if (rating != null && (rating > 0 || (completed ?? 0) > 0))
        'Average rating: ${rating.toStringAsFixed(1)}',
      if (completed != null) 'Completed deliveries: $completed',
      if (metrics.onTimeDeliveryRate != null)
        'On-time rate: ${metrics.onTimeDeliveryRate!.toStringAsFixed(1)}%',
      if (metrics.cancellationRate != null)
        'Cancellation rate: ${metrics.cancellationRate!.toStringAsFixed(1)}%',
    ];
    return RiderSurfaceCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.workspace_premium_outlined,
            color: AgrisellColors.authGreen,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance summary',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  rows.isEmpty
                      ? 'Performance data is not available yet.'
                      : rows.join('  •  '),
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
