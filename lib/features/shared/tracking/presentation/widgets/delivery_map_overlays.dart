import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

import '../styles/delivery_live_map_styles.dart';

class DeliveryStaleGpsWarning extends StatelessWidget {
  const DeliveryStaleGpsWarning({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: DeliveryLiveMapStyles.warningPadding,
    decoration: DeliveryLiveMapStyles.warningDecoration,
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          size: 18,
          color: DeliveryLiveMapStyles.warningColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Stale GPS: Rider location was last updated >2 minutes ago.',
            style: DeliveryLiveMapStyles.warningText,
          ),
        ),
      ],
    ),
  );
}

class DeliveryMapDetailsOverlay extends StatelessWidget {
  const DeliveryMapDetailsOverlay({required this.snapshot, super.key});

  final DeliveryTrackingSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Container(
    padding: DeliveryLiveMapStyles.detailsPadding,
    decoration: DeliveryLiveMapStyles.detailsDecoration,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: DeliveryLiveMapStyles.gpsDot(snapshot.gpsState),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                snapshot.gpsState.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DeliveryLiveMapStyles.gpsLabel(snapshot.gpsState),
              ),
            ),
            if (snapshot.speedKph > 0.5) ...[
              const SizedBox(width: 8),
              _SpeedBadge(speedText: snapshot.speedText),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 16,
              color: AgrisellColors.brandBlack,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                snapshot.arrivalWindowText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DeliveryLiveMapStyles.arrivalText,
              ),
            ),
            if (snapshot.distanceText.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                snapshot.distanceText,
                style: DeliveryLiveMapStyles.distanceText,
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

class _SpeedBadge extends StatelessWidget {
  const _SpeedBadge({required this.speedText});

  final String speedText;

  @override
  Widget build(BuildContext context) => Container(
    padding: DeliveryLiveMapStyles.speedPadding,
    decoration: DeliveryLiveMapStyles.speedDecoration,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.speed_rounded,
          size: 14,
          color: AgrisellColors.authGreen,
        ),
        const SizedBox(width: 4),
        Text(speedText, style: DeliveryLiveMapStyles.speedText),
      ],
    ),
  );
}
