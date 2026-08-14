import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requests.isEmpty)
            _EmptySummary(onOpenList: onOpenList)
          else ...[
            Row(
              children: [
                const _QueueIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${requests.length} request${requests.length == 1 ? '' : 's'} nearby',
                        style: const TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Pickups ready for review in your area.',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final request in preview) ...[
              _RequestPreview(request: request),
              if (request != preview.last)
                const Divider(height: 18, color: AgrisellColors.borderLine),
            ],
            if (requests.length > preview.length) ...[
              const SizedBox(height: 10),
              Text(
                '+${requests.length - preview.length} more request${requests.length - preview.length == 1 ? '' : 's'} available',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onOpenList,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('View all requests'),
              ),
            ),
          ],
          if (isTemporary) ...[
            const SizedBox(height: 10),
            const _TemporaryRequestsNotice(),
          ],
        ],
      ),
    );
  }
}

class _RequestPreview extends StatelessWidget {
  const _RequestPreview({required this.request});

  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AgrisellColors.forestSoft,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: AgrisellColors.authGreen,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (request.deliveryFee > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    'PHP ${request.deliveryFee.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AgrisellColors.authGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.pickupLocation.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                height: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (request.routeDistanceKm != null)
                  RiderStatusPill(
                    label:
                        '${request.routeDistanceKm!.toStringAsFixed(1)} km away',
                    icon: Icons.near_me_outlined,
                    backgroundColor: AgrisellColors.statusBlueBackground,
                    foregroundColor: AgrisellColors.statusBlueText,
                  ),
                if (request.routeEstimatedTravelMinutes != null)
                  RiderStatusPill(
                    label: '${request.routeEstimatedTravelMinutes} min',
                    icon: Icons.schedule_rounded,
                    backgroundColor: AgrisellColors.statusPurpleBackground,
                    foregroundColor: AgrisellColors.statusPurpleText,
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary({required this.onOpenList});

  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        children: [
          _QueueIcon(isMuted: true),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No nearby requests',
                  style: TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Stay online to be matched with ready farm pickups.',
                  style: TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
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

class _QueueIcon extends StatelessWidget {
  const _QueueIcon({this.isMuted = false});

  final bool isMuted;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: isMuted
          ? AgrisellColors.deliveryGray.withValues(alpha: 0.75)
          : AgrisellColors.forestSoft,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Icon(
      Icons.local_shipping_outlined,
      color: isMuted ? AgrisellColors.mutedText : AgrisellColors.authGreen,
      size: 24,
    ),
  );
}

class _TemporaryRequestsNotice extends StatelessWidget {
  const _TemporaryRequestsNotice();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.statusOrangeBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                style: TextStyle(
                  color: AgrisellColors.statusOrangeText,
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
