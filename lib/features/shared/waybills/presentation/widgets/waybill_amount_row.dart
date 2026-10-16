import 'package:flutter/material.dart';

import '../styles/delivery_waybill_styles.dart';

class WaybillAmountRow extends StatelessWidget {
  const WaybillAmountRow({
    required this.label,
    required this.amount,
    this.isTotal = false,
    super.key,
  });

  final String label;
  final String amount;
  final bool isTotal;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final description = Text(
        label,
        style: isTotal
            ? DeliveryWaybillStyles.totalAmountLabel
            : DeliveryWaybillStyles.itemName,
      );
      final price = Text(
        amount,
        style: isTotal
            ? DeliveryWaybillStyles.totalAmountValue
            : DeliveryWaybillStyles.itemTotal,
      );
      if (constraints.maxWidth < 300 ||
          MediaQuery.textScalerOf(context).scale(12) > 18) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [description, const SizedBox(height: 4), price],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: description),
          const SizedBox(width: 12),
          Flexible(child: price),
        ],
      );
    },
  );
}
