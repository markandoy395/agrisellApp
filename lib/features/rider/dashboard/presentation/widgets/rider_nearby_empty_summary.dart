import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_nearby_request_summary_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_nearby_request_preview.dart';

class RiderNearbyEmptySummary extends StatelessWidget {
  const RiderNearbyEmptySummary({required this.onOpenList, super.key});

  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          RiderNearbyQueueIcon(isMuted: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No nearby requests',
                  style: RiderNearbyRequestSummaryStyles.emptyTitleStyle,
                ),
                SizedBox(height: 4),
                Text(
                  'Stay online to be matched with ready farm pickups.',
                  style: RiderNearbyRequestSummaryStyles.emptySubtitleStyle,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onOpenList,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('View all requests'),
        ),
      ),
    ],
  );
}

class RiderNearbyTemporaryNotice extends StatelessWidget {
  const RiderNearbyTemporaryNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: RiderNearbyRequestSummaryStyles.temporaryNoticeDecoration,
      child: const Padding(
        padding: RiderNearbyRequestSummaryStyles.temporaryNoticePadding,
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AgrisellColors.statusOrangeText,
              size: 18,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delivery backend is not connected yet.',
                style: RiderNearbyRequestSummaryStyles.temporaryNoticeTextStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
