import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';

class RiderDetailEarningsCard extends StatelessWidget {
  const RiderDetailEarningsCard({
    required this.request,
    this.active = false,
    super.key,
  });
  final DeliveryRequest request;
  final bool active;
  @override
  Widget build(BuildContext context) {
    final fee = request.feeBreakdown;
    return RiderDetailSection(
      title: active ? 'Earnings' : 'Estimated Rider earning',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        Text(
          '${fee?.currencyCode ?? 'PHP'} ${request.deliveryFee.toStringAsFixed(2)}',
          style: RiderDeliveryReferenceStyles.earning,
        ),
        Text(
          'Estimated ${active ? 'earning' : 'total'}',
          style: RiderDeliveryReferenceStyles.caption,
        ),
        if (!active && fee != null) ...[
          const SizedBox(height: 12),
          for (final component in fee.components.where(
            (item) => item.amount != 0,
          ))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      component.label,
                      style: RiderDeliveryReferenceStyles.caption,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${fee.currencyCode} ${component.amount.toStringAsFixed(2)}',
                    style: RiderDeliveryReferenceStyles.strongCaption,
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class RiderDetailRequirementsCard extends StatelessWidget {
  const RiderDetailRequirementsCard({required this.request, super.key});
  final DeliveryRequest request;
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Vehicle and handling requirements',
    icon: Icons.local_shipping_outlined,
    children: [
      RiderDetailLine(
        icon: Icons.two_wheeler_outlined,
        label: request.requiredVehicleTypes.isEmpty
            ? 'Vehicle requirements unavailable'
            : request.requiredVehicleTypes.map((type) => type.label).join(', '),
      ),
      if (request.requiredCapacityKg case final capacity?)
        RiderDetailLine(
          icon: Icons.scale_outlined,
          label: '$capacity kg capacity required',
        ),
      for (final requirement in request.handlingRequirements)
        RiderDetailLine(
          icon: Icons.inventory_2_outlined,
          label: requirement.type.label,
          value: requirement.instructions.isEmpty
              ? null
              : requirement.instructions,
        ),
    ],
  );
}
