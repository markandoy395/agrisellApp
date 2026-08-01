import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

part 'rider_dashboard_metric_tile.dart';

class RiderDashboardMetricsGrid extends StatelessWidget {
  const RiderDashboardMetricsGrid({
    required this.metrics,
    required this.activeDeliveryCount,
    required this.onOpenEarnings,
    required this.onOpenMessages,
    required this.onOpenNotifications,
    this.todaySummaryAvailable = true,
    this.earningsAvailable = true,
    this.communicationAvailable = true,
    super.key,
  });

  final RiderDashboardMetrics metrics;
  final int activeDeliveryCount;
  final VoidCallback onOpenEarnings;
  final VoidCallback onOpenMessages;
  final VoidCallback onOpenNotifications;
  final bool todaySummaryAvailable;
  final bool earningsAvailable;
  final bool communicationAvailable;

  @override
  Widget build(BuildContext context) {
    final items = <_MetricData>[
      _MetricData(
        'Completed today',
        todaySummaryAvailable ? '${metrics.todayCompletedDeliveries}' : '—',
        Icons.task_alt_outlined,
      ),
      _MetricData('Active now', '$activeDeliveryCount', Icons.route_outlined),
      if (metrics.cancelledOrFailedDeliveries != null)
        _MetricData(
          'Cancelled or failed',
          '${metrics.cancelledOrFailedDeliveries}',
          Icons.cancel_outlined,
        ),
    ];
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final width = items.length == 2
                ? (constraints.maxWidth - 10) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final item in items)
                  SizedBox(
                    width: width,
                    child: _MetricTile(data: item),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        RiderSurfaceCard(
          child: Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: AgrisellColors.authGreen,
                size: 26,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earningsAvailable
                          ? 'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}'
                          : 'Not available',
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      !earningsAvailable
                          ? 'Earnings data has not been connected.'
                          : metrics.pendingEarnings == null
                          ? 'Estimated earnings today'
                          : 'PHP ${metrics.pendingEarnings!.toStringAsFixed(2)} pending',
                      style: const TextStyle(
                        color: AgrisellColors.mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onOpenEarnings, child: const Text('Open')),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CountAction(
                label: 'Messages',
                count: communicationAvailable
                    ? metrics.unreadMessageCount
                    : null,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: onOpenMessages,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CountAction(
                label: 'Notifications',
                count: communicationAvailable
                    ? metrics.unreadNotificationCount
                    : null,
                icon: Icons.notifications_none_rounded,
                onPressed: onOpenNotifications,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CountAction extends StatelessWidget {
  const _CountAction({
    required this.label,
    required this.count,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final int? count;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 17),
    label: Text(
      count == null ? label : '$label ($count)',
      overflow: TextOverflow.ellipsis,
    ),
  );
}
