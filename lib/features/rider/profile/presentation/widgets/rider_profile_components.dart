import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_components_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
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
        Text(value, style: SharedPresentationStyles.greenTitleExtraBold),
        const SizedBox(height: 4),
        Text(label, style: SharedPresentationStyles.mutedCaptionSemibold),
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
        Text(title, style: SharedPresentationStyles.headingSubtitleExtraBold),
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
          child: Text(value, style: RiderProfileComponentsStyles.valueText),
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
    title: Text(label, style: RiderProfileComponentsStyles.labelText(color)),
    trailing: Icon(Icons.chevron_right_rounded, color: color),
    onTap: onTap,
  );
}
