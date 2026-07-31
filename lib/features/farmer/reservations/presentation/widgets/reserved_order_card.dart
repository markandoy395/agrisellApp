import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_reservation.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserve_action_buttons.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/reserved_product_row.dart';

class ReservedOrderCard extends StatelessWidget {
  const ReservedOrderCard({
    required this.order,
    required this.onMessageBuyer,
    required this.onConfirmOrder,
    super.key,
  });

  final FarmerReservation order;
  final VoidCallback onMessageBuyer;
  final VoidCallback? onConfirmOrder;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardPadding = width < 380 ? 12.0 : 14.0;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BuyerDetails(order: order),
            const SizedBox(height: 12),
            MessageBuyerButton(onPressed: onMessageBuyer),
            if (order.products.isNotEmpty) ...[
              const SizedBox(height: 15),
              const Divider(height: 1, color: AgrisellColors.borderLine),
              const SizedBox(height: 4),
              for (var index = 0; index < order.products.length; index++) ...[
                ReservedProductRow(product: order.products[index]),
                if (index < order.products.length - 1)
                  const Divider(height: 1, color: AgrisellColors.borderLine),
              ],
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeOutCubic,
                child: order.status == FarmerReservationStatus.toShip
                    ? const ToShipStatusNotice(key: ValueKey('to-ship-notice'))
                    : ConfirmDeliveryButton(
                        key: const ValueKey('confirm-delivery-button'),
                        onPressed: onConfirmOrder,
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BuyerDetails extends StatelessWidget {
  const _BuyerDetails({required this.order});

  final FarmerReservation order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BuyerDetailLine(label: 'Name of Buyer', value: order.buyerName),
        const SizedBox(height: 4),
        _BuyerDetailLine(label: 'Contact Number', value: order.contactNumber),
        const SizedBox(height: 4),
        _BuyerDetailLine(label: 'Address', value: order.address),
      ],
    );
  }
}

class _BuyerDetailLine extends StatelessWidget {
  const _BuyerDetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: value),
        ],
      ),
      style: const TextStyle(
        color: AgrisellColors.brandBlack,
        fontSize: 12,
        height: 1.26,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
