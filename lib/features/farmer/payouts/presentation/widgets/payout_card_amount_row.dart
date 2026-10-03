import 'package:flutter/material.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_text_styles.dart';

class PayoutCardAmountRow extends StatelessWidget {
  const PayoutCardAmountRow({
    required this.amountLabel,
    required this.amount,
    required this.date,
    required this.description,
    super.key,
  });

  final String amountLabel;
  final String amount;
  final String date;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: PayoutLayoutStyles.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: PayoutLayoutStyles.alignStart,
          children: [
            Text(amountLabel, style: PayoutTextStyles.mutedLabel),
            const SizedBox(height: PayoutLayoutStyles.tinyGap),
            Text(amount, style: PayoutTextStyles.cardAmount),
          ],
        ),
        Column(
          crossAxisAlignment: PayoutLayoutStyles.alignEnd,
          children: [
            Text(date, style: PayoutTextStyles.mutedLabel),
            const SizedBox(height: PayoutLayoutStyles.tinyGap),
            Text(description, style: PayoutTextStyles.description),
          ],
        ),
      ],
    );
  }
}
