part of 'rider_dashboard_metrics.dart';

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    padding: RiderDashboardMetricsStyles.tilePadding,
    child: Row(
      children: [
        Container(
          width: RiderDashboardMetricsStyles.tileSize,
          height: RiderDashboardMetricsStyles.tileSize,
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
        RiderDashboardMetricsStyles.horizontalGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: RiderDashboardMetricsStyles.tileValueStyle,
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RiderDashboardMetricsStyles.tileLabelStyle,
              ),
            ],
          ),
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
