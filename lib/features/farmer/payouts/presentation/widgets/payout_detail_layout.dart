import 'package:flutter/material.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import 'payout_detail_amount.dart';

class PayoutDetailLayout extends StatelessWidget {
  const PayoutDetailLayout({
    required this.title,
    required this.amountLabel,
    required this.amount,
    required this.statusLabel,
    required this.statusColor,
    required this.backgroundColor,
    required this.sectionTitle,
    required this.children,
    super.key,
  });

  final String title;
  final String amountLabel;
  final String amount;
  final String statusLabel;
  final Color statusColor;
  final Color backgroundColor;
  final String sectionTitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: PayoutLayoutStyles.detailPadding,
        child: Column(
          mainAxisSize: PayoutLayoutStyles.shrinkWrap,
          crossAxisAlignment: PayoutLayoutStyles.alignStart,
          children: [
            Center(
              child: Container(
                width: PayoutLayoutStyles.dragHandleWidth,
                height: PayoutLayoutStyles.smallGap,
                decoration: PayoutSurfaceStyles.dragHandle,
              ),
            ),
            const SizedBox(height: PayoutLayoutStyles.detailHeaderGap),
            Row(
              children: [
                Expanded(child: Text(title, style: PayoutTextStyles.heading)),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(
                    Icons.close_rounded,
                    size: PayoutLayoutStyles.closeIconSize,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: PayoutLayoutStyles.detailHeaderGap),
            PayoutDetailAmount(
              label: amountLabel,
              amount: amount,
              statusLabel: statusLabel,
              statusColor: statusColor,
              backgroundColor: backgroundColor,
            ),
            const SizedBox(height: PayoutLayoutStyles.detailSectionGap),
            Text(sectionTitle, style: PayoutTextStyles.sectionHeading),
            const SizedBox(height: PayoutLayoutStyles.contentGap),
            ...children,
          ],
        ),
      ),
    );
  }
}

class PayoutSummaryLine extends StatelessWidget {
  const PayoutSummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: PayoutLayoutStyles.summaryLinePadding,
      child: Row(
        crossAxisAlignment: PayoutLayoutStyles.alignStart,
        children: [
          SizedBox(
            width: PayoutLayoutStyles.summaryLabelWidth,
            child: Text(label, style: PayoutTextStyles.mutedLabel),
          ),
          Expanded(child: Text(value, style: PayoutTextStyles.referenceLabel)),
        ],
      ),
    );
  }
}
