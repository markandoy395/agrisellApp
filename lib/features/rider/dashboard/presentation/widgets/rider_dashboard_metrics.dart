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
        label: 'Completed',
        value: '${metrics.todayCompletedDeliveries}',
        icon: Icons.task_alt_outlined,
        accentColor: AgrisellColors.statusGreenText,
        backgroundColor: AgrisellColors.statusGreenBackground,
      ),
      _MetricData(
        label: 'Active now',
        value: '$activeDeliveryCount',
        icon: Icons.route_outlined,
        accentColor: AgrisellColors.statusBlueText,
        backgroundColor: AgrisellColors.statusBlueBackground,
      ),
      _MetricData(
        label: 'Issues',
        value: '${metrics.cancelledOrFailedDeliveries ?? 0}',
        icon: Icons.report_problem_outlined,
        accentColor: AgrisellColors.statusOrangeText,
        backgroundColor: AgrisellColors.statusOrangeBackground,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 560 ? 3 : 1;
            final width = (constraints.maxWidth - (columns - 1) * 10) / columns;
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
        _EarningsCard(
          metrics: metrics,
          isAvailable: earningsAvailable,
          onOpenEarnings: onOpenEarnings,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _CountAction(
                label: 'Messages',
                count: metrics.unreadMessageCount,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: onOpenMessages,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _CountAction(
                label: 'Notifications',
                count: metrics.unreadNotificationCount,
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

class _EarningsCard extends StatelessWidget {
  const _EarningsCard({
    required this.metrics,
    required this.isAvailable,
    required this.onOpenEarnings,
  });

  final RiderDashboardMetrics metrics;
  final bool isAvailable;
  final VoidCallback onOpenEarnings;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AgrisellColors.limeSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AgrisellColors.authGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                !isAvailable
                    ? 'Earnings will appear after completed deliveries.'
                    : metrics.pendingEarnings == null
                    ? 'Estimated earnings today'
                    : 'PHP ${metrics.pendingEarnings!.toStringAsFixed(2)} pending',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(onPressed: onOpenEarnings, child: const Text('Open')),
      ],
    ),
  );
}

class _CountAction extends StatelessWidget {
  const _CountAction({
    required this.label,
    required this.count,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final int count;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 17),
    label: Text(
      '$label ($count)',
      overflow: TextOverflow.ellipsis,
    ),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
}
