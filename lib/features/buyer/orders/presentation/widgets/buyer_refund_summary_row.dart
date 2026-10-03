import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_detail_styles.dart';

/// Single transaction summary row displaying a label and bold value.
class BuyerRefundSummaryRow extends StatelessWidget {
  const BuyerRefundSummaryRow({
    required this.label,
    required this.value,
    super.key,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: BuyerRefundDetailStyles.summaryRowPadding,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: BuyerRefundDetailStyles.summaryLabel,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: BuyerRefundDetailStyles.summaryValue,
          ),
        ),
      ],
    ),
  );
}
