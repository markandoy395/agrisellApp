part of 'rider_dashboard_metrics.dart';

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
    padding: RiderDashboardMetricsStyles.earningsPadding,
    child: Row(
      children: [
        Container(
          width: RiderDashboardMetricsStyles.earningsIconBoxSize,
          height: RiderDashboardMetricsStyles.earningsIconBoxSize,
          alignment: Alignment.center,
          decoration: RiderDashboardMetricsCardsStyles.containerDecoration,
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: RiderDashboardMetricsStyles.earningsIconColor,
            size: RiderDashboardMetricsStyles.earningsIconSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}',
                style: RiderDashboardMetricsStyles.earningsValueStyle,
              ),
              const SizedBox(height: 4),
              Text(
                !isAvailable
                    ? 'Earnings will appear after completed deliveries.'
                    : metrics.pendingEarnings == null
                    ? 'Estimated earnings today'
                    : 'PHP ${metrics.pendingEarnings!.toStringAsFixed(2)} pending',
                style: RiderDashboardMetricsStyles.earningsSubtitleStyle,
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
    icon: Icon(icon, size: RiderDashboardMetricsStyles.countActionIconSize),
    label: Text('$label ($count)', overflow: TextOverflow.ellipsis),
    style: RiderDashboardMetricsStyles.countActionButtonStyle,
  );
}
