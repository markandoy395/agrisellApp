import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_metric_tile_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_metrics_cards_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_dashboard_metrics_styles.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

part 'rider_dashboard_metric_tile.dart';
part 'rider_dashboard_metrics_cards.dart';

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
            final width =
                (constraints.maxWidth -
                    (columns - 1) *
                        RiderDashboardMetricsStyles.gridItemSpacing) /
                columns;
            return Wrap(
              spacing: RiderDashboardMetricsStyles.gridItemSpacing,
              runSpacing: RiderDashboardMetricsStyles.gridItemSpacing,
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
        RiderDashboardMetricsStyles.verticalGap,
        _EarningsCard(
          metrics: metrics,
          isAvailable: earningsAvailable,
          onOpenEarnings: onOpenEarnings,
        ),
        RiderDashboardMetricsStyles.verticalGap,
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
            RiderDashboardMetricsStyles.horizontalGap,
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
