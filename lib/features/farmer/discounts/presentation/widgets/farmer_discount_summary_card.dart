import 'package:flutter/material.dart';
import '../styles/farmer_discounts_styles.dart';

class FarmerDiscountSummaryCard extends StatelessWidget {
  const FarmerDiscountSummaryCard(
    this.label,
    this.count,
    this.bg,
    this.textColor, {
    super.key,
  });
  final String label;
  final String count;
  final Color bg;
  final Color textColor;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: FarmerDiscountsStyles.summaryPadding,
        decoration: FarmerDiscountsStyles.summaryDecoration(bg),
        child: Column(
          children: [
            Text(count, style: FarmerDiscountsStyles.summaryCount(textColor)),
            const SizedBox(height: 2),
            Text(label, style: FarmerDiscountsStyles.summaryLabel),
          ],
        ),
      ),
    );
  }
}
