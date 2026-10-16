import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_profile_design_components.dart';

class RiderProfilePerformanceCard extends StatelessWidget {
  const RiderProfilePerformanceCard({this.summary, super.key});
  final RiderRatingsSummary? summary;
  @override
  Widget build(BuildContext context) {
    final data = summary;
    final available = data != null && !data.isEmpty;
    final metrics = [
      (
        Icons.star_rounded,
        AgrisellColors.accentOrange,
        available ? data.averageRating.toStringAsFixed(1) : '—',
        'Rating',
      ),
      (
        Icons.inventory_2_rounded,
        AgrisellColors.authGreen,
        available ? '${data.completedDeliveries}' : '—',
        'Deliveries',
      ),
      (
        Icons.schedule_rounded,
        AgrisellColors.statusBlueText,
        available ? '${data.onTimeDeliveryRate.toStringAsFixed(0)}%' : '—',
        'On time',
      ),
    ];
    return RiderProfileCard(
      soft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery performance', style: RiderProfileDesignStyles.title),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final metric in metrics)
                Expanded(
                  child: Column(
                    children: [
                      Icon(metric.$1, color: metric.$2, size: 28),
                      const SizedBox(height: 5),
                      Text(metric.$3, style: RiderProfileDesignStyles.value),
                      Text(
                        metric.$4,
                        style: RiderProfileDesignStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
