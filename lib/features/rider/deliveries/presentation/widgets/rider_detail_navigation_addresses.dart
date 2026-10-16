import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';

class RiderDeliveryNavigationAddresses extends StatelessWidget {
  const RiderDeliveryNavigationAddresses({
    required this.request,
    required this.onPickup,
    required this.onDelivery,
    super.key,
  });
  final DeliveryRequest request;
  final VoidCallback onPickup;
  final VoidCallback onDelivery;
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Addresses',
    icon: Icons.route_rounded,
    children: [
      _address(
        'Pick up from',
        request.pickupLocation.address,
        AgrisellColors.authGreen,
        onPickup,
      ),
      const SizedBox(height: 16),
      _address(
        'Deliver to',
        request.deliveryLocation.address,
        AgrisellColors.statusRedText,
        onDelivery,
      ),
    ],
  );

  Widget _address(
    String title,
    String address,
    Color color,
    VoidCallback onTap,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final narrow =
          constraints.maxWidth < 310 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.2;
      final navigate = TextButton.icon(
        style: RiderDeliveryReferenceStyles.navigate,
        onPressed: onTap,
        icon: const Icon(Icons.navigation_outlined, size: 17),
        label: const Text('Navigate'),
      );
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on_rounded, color: color, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: RiderDeliveryReferenceStyles.strongCaption),
                Text(address, style: RiderDeliveryReferenceStyles.caption),
                if (narrow)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: navigate,
                  ),
              ],
            ),
          ),
          if (!narrow) ...[const SizedBox(width: 10), navigate],
        ],
      );
    },
  );
}
