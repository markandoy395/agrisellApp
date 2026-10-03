import 'package:flutter/material.dart';

import '../styles/farmer_restock_dialog_styles.dart';

class FarmerRestockStockSummary extends StatelessWidget {
  const FarmerRestockStockSummary({
    required this.currentStock,
    required this.resultingStock,
    required this.unit,
    super.key,
  });

  final double currentStock;
  final double resultingStock;
  final String unit;

  @override
  Widget build(BuildContext context) => Container(
    padding: FarmerRestockDialogStyles.stockSummaryPadding,
    decoration: FarmerRestockDialogStyles.stockSummaryDecoration,
    child: Row(
      children: [
        Expanded(child: _value('Current stock', currentStock)),
        const Icon(
          Icons.arrow_forward_rounded,
          color: FarmerRestockDialogStyles.stockSummaryArrowColor,
          size: FarmerRestockDialogStyles.stockSummaryArrowSize,
        ),
        Expanded(
          child: _value('After restock', resultingStock, alignEnd: true),
        ),
      ],
    ),
  );

  Widget _value(String label, double value, {bool alignEnd = false}) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: FarmerRestockDialogStyles.stockSummaryLabelStyle,
      ),
      FarmerRestockDialogStyles.spacingStockValue,
      Text(
        '${_format(value)} $unit',
        style: FarmerRestockDialogStyles.stockSummaryValueStyle,
      ),
    ],
  );

  String _format(double value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '');
}
