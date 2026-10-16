import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import '../styles/rider_cash_out_dialog_styles.dart';

class RiderCashOutAmountField extends StatelessWidget {
  const RiderCashOutAmountField({
    required this.controller,
    required this.availableEarnings,
    required this.onQuickAmountSelected,
    super.key,
  });

  final TextEditingController controller;
  final double availableEarnings;
  final ValueChanged<double> onQuickAmountSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Amount (₱)',
          style: RiderCashOutDialogStyles.sectionLabel,
        ),
        const SizedBox(height: RiderCashOutDialogStyles.inputLabelGap),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: RiderCashOutDialogStyles.inputDecoration(
            hintText: 'Enter amount (e.g. 500)',
            prefixText: '₱ ',
            prefixStyle: RiderCashOutDialogStyles.amountPrefix,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter an amount';
            }
            final parsed = double.tryParse(value.trim());
            if (parsed == null ||
                !parsed.isFinite ||
                parsed <= 0 ||
                !RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value.trim())) {
              return 'Please enter a valid amount greater than 0';
            }
            if (parsed > availableEarnings) {
              return 'Amount exceeds available earnings (${formatRiderCurrency(availableEarnings)})';
            }
            return null;
          },
        ),
        Padding(
          padding: RiderCashOutDialogStyles.quickChipsMargin,
          child: Wrap(
            spacing: RiderCashOutDialogStyles.quickChipsSpacing,
            children: [
              if (availableEarnings >= 200)
                ActionChip(
                  label: const Text('₱200'),
                  onPressed: () => onQuickAmountSelected(200),
                  labelStyle: RiderCashOutDialogStyles.quickChipLabel,
                ),
              if (availableEarnings >= 500)
                ActionChip(
                  label: const Text('₱500'),
                  onPressed: () => onQuickAmountSelected(500),
                  labelStyle: RiderCashOutDialogStyles.quickChipLabel,
                ),
              if (availableEarnings >= 1000)
                ActionChip(
                  label: const Text('₱1,000'),
                  onPressed: () => onQuickAmountSelected(1000),
                  labelStyle: RiderCashOutDialogStyles.quickChipLabel,
                ),
              if (availableEarnings > 0)
                ActionChip(
                  label: const Text('All'),
                  onPressed: () => onQuickAmountSelected(availableEarnings),
                  labelStyle: RiderCashOutDialogStyles.quickChipAllLabel,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
