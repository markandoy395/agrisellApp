import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_deliveries_design_styles.dart';

class RiderDeliveryAddressPair extends StatelessWidget {
  const RiderDeliveryAddressPair({required this.request, super.key});
  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _stop(
        'Pick up from',
        request.pickupLocation.address,
        AgrisellColors.authGreen,
      ),
      const SizedBox(height: 8),
      _stop(
        'Deliver to',
        request.deliveryLocation.address,
        AgrisellColors.statusRedText,
      ),
    ],
  );

  Widget _stop(String title, String address, Color color) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.location_on, color: color, size: 20),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: RiderDeliveriesDesignStyles.label),
            Text(address, style: RiderDeliveriesDesignStyles.caption),
          ],
        ),
      ),
    ],
  );
}
