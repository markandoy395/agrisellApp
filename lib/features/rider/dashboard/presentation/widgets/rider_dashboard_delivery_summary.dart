import 'package:flutter/material.dart';
import '../styles/rider_home_design_styles.dart';
import '../styles/rider_reference_styles.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_nearby_request_summary_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_nearby_empty_summary.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_nearby_request_preview.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

class RiderNearbyRequestSummary extends StatelessWidget {
  const RiderNearbyRequestSummary({
    required this.requests,
    required this.isTemporary,
    required this.onOpenList,
    super.key,
  });

  final List<DeliveryRequest> requests;
  final bool isTemporary;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final preview = requests.take(3).toList();
    return RiderSurfaceCard(
      decoration: RiderHomeDesignStyles.card,
      padding: RiderNearbyRequestSummaryStyles.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requests.isEmpty)
            RiderNearbyEmptySummary(onOpenList: onOpenList)
          else ...[
            Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: RiderReferenceStyles.green,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ready for pickup',
                        style: RiderReferenceStyles.title,
                      ),
                      Text(
                        '${requests.length} request${requests.length == 1 ? '' : 's'} nearby',
                        style: RiderNearbyRequestSummaryStyles.headerTitleStyle,
                      ),
                      const SizedBox(height: 3),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onOpenList,
                  style: RiderReferenceStyles.linkButton,
                  child: const Text('View all ›'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Pickups ready for review in your area.',
              style: RiderReferenceStyles.caption,
            ),
            const SizedBox(height: 14),
            for (final request in preview) ...[
              InkWell(
                onTap: onOpenList,
                child: RiderNearbyRequestPreview(request: request),
              ),
              if (request != preview.last)
                const Divider(
                  height: RiderNearbyRequestSummaryStyles.dividerHeight,
                  color: RiderNearbyRequestSummaryStyles.dividerColor,
                ),
            ],
            if (requests.length > preview.length) ...[
              const SizedBox(height: 10),
              Text(
                '+${requests.length - preview.length} more request${requests.length - preview.length == 1 ? '' : 's'} available',
                style: RiderNearbyRequestSummaryStyles.moreRequestsStyle,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: RiderReferenceStyles.neutralButton,
                onPressed: onOpenList,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View all requests'),
              ),
            ),
          ],
          if (isTemporary) ...[
            const SizedBox(height: 10),
            const RiderNearbyTemporaryNotice(),
          ],
        ],
      ),
    );
  }
}
