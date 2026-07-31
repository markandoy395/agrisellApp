import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderProfileMetricsCard extends StatelessWidget {
  const RiderProfileMetricsCard({this.summary, super.key});
  final RiderRatingsSummary? summary;
  @override
  Widget build(BuildContext context) {
    final data = summary;
    final hasData = data != null && !data.isEmpty;
    return RiderSurfaceCard(
      child: Row(
        children: [
          _Metric(
            value: hasData ? data.averageRating.toStringAsFixed(1) : '—',
            label: 'Rating',
          ),
          _Metric(
            value: hasData ? '${data.completedDeliveries}' : '—',
            label: 'Deliveries',
          ),
          _Metric(
            value: hasData
                ? '${data.onTimeDeliveryRate.toStringAsFixed(0)}%'
                : '—',
            label: 'On time',
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AgrisellColors.authGreen,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class RiderProfileInformationCard extends StatelessWidget {
  const RiderProfileInformationCard({
    required this.title,
    required this.rows,
    super.key,
  });

  final String title;
  final List<RiderProfileInfoRow> rows;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AgrisellColors.headingGreen,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        for (final row in rows) row,
      ],
    ),
  );
}

class RiderProfileInfoRow extends StatelessWidget {
  const RiderProfileInfoRow(this.icon, this.value, {super.key});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AgrisellColors.mutedText, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class RiderProfileAction extends StatelessWidget {
  const RiderProfileAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.color = AgrisellColors.authGreen,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: color, size: 20),
    title: Text(
      label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
    ),
    trailing: Icon(Icons.chevron_right_rounded, color: color),
    onTap: onTap,
  );
}
