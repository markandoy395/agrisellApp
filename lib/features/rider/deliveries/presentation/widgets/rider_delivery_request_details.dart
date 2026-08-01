import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

class RiderRequestProductImage extends StatelessWidget {
  const RiderRequestProductImage({
    required this.url,
    required this.productName,
    super.key,
  });

  final String? url;
  final String productName;

  @override
  Widget build(BuildContext context) {
    final imagePath = url?.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: imagePath == null || imagePath.isEmpty
            ? _imageFallback
            : imagePath.startsWith('http://') ||
                  imagePath.startsWith('https://')
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
                semanticLabel: '$productName product image',
                errorBuilder: (_, _, _) => _imageFallback,
              )
            : Image.asset(
                imagePath,
                fit: BoxFit.cover,
                semanticLabel: '$productName product image',
                errorBuilder: (_, _, _) => _imageFallback,
              ),
      ),
    );
  }

  Widget get _imageFallback => Semantics(
    label: '$productName product image unavailable',
    child: const ColoredBox(
      color: AgrisellColors.limeSoft,
      child: Icon(Icons.inventory_2_outlined),
    ),
  );
}

class RiderRequestDetailLine extends StatelessWidget {
  const RiderRequestDetailLine({
    required this.icon,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AgrisellColors.mutedText, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AgrisellColors.brandBlack,
              fontSize: 12,
              height: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class RiderRequestMetaChip extends StatelessWidget {
  const RiderRequestMetaChip({
    required this.icon,
    required this.label,
    super.key,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
    decoration: BoxDecoration(
      color: AgrisellColors.searchBackground,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AgrisellColors.mutedText),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

void showRiderRequestDetails(BuildContext context, DeliveryRequest request) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.productName,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          RiderRequestDetailLine(
            icon: Icons.storefront_outlined,
            text: 'Seller: ${request.sellerName}',
          ),
          RiderRequestDetailLine(
            icon: Icons.person_outline_rounded,
            text: 'Customer: ${request.buyerName}',
          ),
          RiderRequestDetailLine(
            icon: Icons.place_outlined,
            text: 'Pick up from: ${request.pickupLocation.address}',
          ),
          RiderRequestDetailLine(
            icon: Icons.location_on_outlined,
            text: 'Deliver to: ${request.deliveryLocation.address}',
          ),
          const SizedBox(height: 8),
          Text(
            'Fee: ₱${request.deliveryFee.toStringAsFixed(2)} • ${request.routeDistanceKm?.toStringAsFixed(1) ?? 'Distance pending'} km • ${request.routeEstimatedTravelMinutes ?? 'ETA pending'} min',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          if (request.pickupInstructions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Pickup: ${request.pickupInstructions}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
          if (request.deliveryInstructions.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Delivery: ${request.deliveryInstructions}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    ),
  );
}
