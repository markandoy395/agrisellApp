import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import 'rider_detail_card.dart';

class RiderDetailOtherInformation extends StatelessWidget {
  const RiderDetailOtherInformation({required this.request, super.key});
  final DeliveryRequest request;
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Other information',
    icon: Icons.info_rounded,
    children: [
      if (request.isFarmerSelectedRequest)
        const RiderDetailLine(
          icon: Icons.person_search_outlined,
          label: 'Selected by the farmer',
          value: 'Accept or decline before expiry',
        ),
      if (request.paymentMethod.isNotEmpty)
        RiderDetailLine(
          icon: Icons.payments_outlined,
          label: 'Payment method',
          value: request.paymentMethod,
        ),
      if (request.cashOnDelivery case final cash?) ...[
        RiderDetailLine(
          icon: Icons.account_balance_wallet_outlined,
          label: 'COD amount to collect',
          value:
              '${cash.currencyCode} ${cash.amountToCollect.toStringAsFixed(2)}',
        ),
        RiderDetailLine(
          icon: Icons.receipt_long_outlined,
          label: cash.remittanceRequired
              ? 'Cash remittance is required'
              : 'No Rider remittance required',
          value: cash.riderCashResponsibility.isEmpty
              ? null
              : cash.riderCashResponsibility,
        ),
      ],
      RiderDetailLine(
        icon: Icons.priority_high_rounded,
        label: 'Priority',
        value: request.priority.name,
        color: request.priority == DeliveryPriority.high
            ? AgrisellColors.statusRedText
            : AgrisellColors.authGreen,
      ),
      if (request.expiresAt case final expiry?)
        RiderDetailLine(
          icon: Icons.timer_outlined,
          label: 'Request expiry',
          value: riderDetailDate(context, expiry),
        ),
      if (request.cancellationConditions.isNotEmpty)
        RiderDetailLine(
          icon: Icons.policy_outlined,
          label: 'Cancellation',
          value: request.cancellationConditions,
        ),
    ],
  );
}
