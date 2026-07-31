part of 'rider_dashboard_metrics.dart';

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.data});

  final _MetricData data;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    padding: const EdgeInsets.all(12),
    child: Row(
      children: [
        Icon(data.icon, color: AgrisellColors.authGreen, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                data.label,
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
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

class _MetricData {
  const _MetricData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
