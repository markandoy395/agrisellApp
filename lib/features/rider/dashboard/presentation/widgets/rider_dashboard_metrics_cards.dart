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
    decoration: RiderHomeDesignStyles.card,
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
              const Text('Earnings', style: RiderHomeDesignStyles.title),
              const SizedBox(height: 4),
              if (isAvailable && metrics.todayEstimatedEarnings > 0)
                Text(
                  'PHP ${metrics.todayEstimatedEarnings.toStringAsFixed(2)}',
                  style: RiderDashboardMetricsStyles.earningsValueStyle,
                ),
              const SizedBox(height: 4),
              Text(
                !isAvailable || metrics.todayEstimatedEarnings == 0
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
        TextButton.icon(
          onPressed: onOpenEarnings,
          style: RiderHomeDesignStyles.secondaryButton,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.chevron_right_rounded, size: 16),
          label: const Text('Open'),
        ),
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
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label ($count)',
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: RiderSurfaceCard(
        decoration: RiderHomeDesignStyles.card,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: label == 'Messages'
                  ? AgrisellColors.statusBlueText
                  : RiderHomeDesignStyles.red,
            ),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: RiderHomeDesignStyles.body)),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: RiderHomeDesignStyles.badge,
              child: Text('$count', style: RiderHomeDesignStyles.badgeText),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: RiderHomeDesignStyles.muted,
            ),
          ],
        ),
      ),
    ),
  );
}
