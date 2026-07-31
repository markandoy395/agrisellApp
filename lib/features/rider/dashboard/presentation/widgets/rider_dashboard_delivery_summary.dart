import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
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
    final preview = requests.take(2).toList();
    return RiderSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (requests.isEmpty)
            const _EmptySummary()
          else ...[
            Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  color: AgrisellColors.authGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${requests.length} nearby request${requests.length == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final request in preview) ...[
              _RequestPreview(request: request),
              if (request != preview.last) const Divider(height: 14),
            ],
          ],
          if (isTemporary) ...[
            const SizedBox(height: 8),
            const Text(
              'Delivery backend not connected',
              style: TextStyle(
                color: AgrisellColors.statusOrangeText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onOpenList,
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: const Text('View all requests'),
            ),
          ),
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
    children: [
      const Icon(Icons.inventory_2_outlined, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              request.pickupLocation.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _EmptySummary extends StatelessWidget {
  const _EmptySummary();

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Icon(Icons.local_shipping_outlined, color: AgrisellColors.mutedText),
      SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No nearby requests',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'New ready-for-pickup summaries will appear here.',
              style: TextStyle(
                color: AgrisellColors.mutedText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
