part of 'rider_dashboard_metrics.dart';

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    decoration: RiderHomeDesignStyles.card,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: RiderDashboardMetricTileStyles.containerDecoration(
                data.backgroundColor,
              ),
              child: Icon(
                data.icon,
                color: data.accentColor,
                size: RiderDashboardMetricsStyles.tileIconSize,
              ),
            ),
            const SizedBox(width: 6),
            Text(data.value, style: RiderHomeDesignStyles.metric),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: RiderHomeDesignStyles.metricLabel,
        ),
      ],
    ),
  );
}

class _MetricData {
  const _MetricData({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.backgroundColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color backgroundColor;
}
