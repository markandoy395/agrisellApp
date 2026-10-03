import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_information_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

class FarmerOrderBuyerInformation extends StatelessWidget {
  const FarmerOrderBuyerInformation({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) => FarmerOrderInformationSection(
    title: 'Buyer Information',
    children: [
      FarmerOrderInformationLine(
        label: 'Name',
        value: _valueOr(order.buyerName, 'Buyer name not available'),
      ),
      FarmerOrderInformationLine(
        label: 'Contact Number',
        value: _valueOr(order.phoneNumber, 'Not provided'),
      ),
      FarmerOrderInformationLine(
        label: 'Delivery Address',
        value: _valueOr(order.deliveryAddress, 'No delivery address available'),
      ),
    ],
  );
}

class FarmerOrderInformation extends StatelessWidget {
  const FarmerOrderInformation({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final itemNames = order.items
        .map((item) => item.productName.trim())
        .where((name) => name.isNotEmpty)
        .join(', ');
    return FarmerOrderInformationSection(
      title: 'Order Information',
      children: [
        FarmerOrderInformationLine(
          label: 'Order/Reservation ID',
          value: _valueOr(order.id, 'Not available'),
        ),
        FarmerOrderInformationLine(
          label: 'Items',
          value: _valueOr(itemNames, 'No items available'),
        ),
        FarmerOrderInformationLine(
          label: 'Quantity',
          value: order.totalQuantity.toString(),
        ),
        FarmerOrderInformationLine(
          label: 'Total Amount',
          value: formatBasketPeso(order.total),
        ),
        FarmerOrderInformationLine(
          label: 'Order Date',
          value: _formatDate(order.placedAt),
        ),
        FarmerOrderInformationLine(
          label: 'Order Time',
          value: _formatTime(order.placedAt),
        ),
        FarmerOrderInformationLine(
          label: 'Order Status',
          value: order.isExpired ? 'Expired' : order.status.label,
        ),
      ],
    );
  }
}

class FarmerOrderInformationSection extends StatelessWidget {
  const FarmerOrderInformationSection({
    required this.title,
    required this.children,
    super.key,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: FarmerOrderInformationStyles.containerDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: SharedPresentationStyles.headingTitleExtraBold),
        const SizedBox(height: 12),
        for (var index = 0; index < children.length; index++) ...[
          children[index],
          if (index < children.length - 1) const SizedBox(height: 11),
        ],
      ],
    ),
  );
}

class FarmerOrderInformationLine extends StatelessWidget {
  const FarmerOrderInformationLine({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: SharedPresentationStyles.mutedCaptionSemibold),
      const SizedBox(height: 2),
      SelectableText(value, style: FarmerOrderInformationStyles.textStyle),
    ],
  );
}

String _valueOr(String value, String fallback) {
  final normalized = value.trim();
  return normalized.isEmpty ? fallback : normalized;
}

String _formatDate(DateTime value) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final local = value.toLocal();
  return '${months[local.month - 1]} ${local.day}, ${local.year}';
}

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}
