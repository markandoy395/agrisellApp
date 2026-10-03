import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import '../styles/rider_cash_out_dialog_styles.dart';

class RiderCashOutDestinationPicker extends StatelessWidget {
  const RiderCashOutDestinationPicker({
    required this.methods,
    required this.selectedMethod,
    required this.onChanged,
    super.key,
  });

  final List<RiderWithdrawalMethod> methods;
  final RiderWithdrawalMethod? selectedMethod;
  final ValueChanged<RiderWithdrawalMethod?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Withdrawal Destination',
          style: RiderCashOutDialogStyles.sectionLabel,
        ),
        const SizedBox(height: RiderCashOutDialogStyles.labelGap),
        if (methods.isEmpty)
          Container(
            padding: RiderCashOutDialogStyles.emptyMethodPadding,
            decoration: RiderCashOutDialogStyles.emptyMethodDecoration,
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: RiderCashOutDialogStyles.emptyMethodIconSize,
                  color: AgrisellColors.statusOrangeText,
                ),
                SizedBox(width: RiderCashOutDialogStyles.emptyMethodGap),
                Expanded(
                  child: Text(
                    'No withdrawal method configured. Please add one first.',
                    style: RiderCashOutDialogStyles.emptyMethodText,
                  ),
                ),
              ],
            ),
          )
        else
          DropdownButtonFormField<RiderWithdrawalMethod>(
            isExpanded: true,
            initialValue: selectedMethod,
            items: [
              for (final m in methods)
                DropdownMenuItem(
                  value: m,
                  child: Text(
                    '${m.methodLabel} (${m.accountNumber}) - ${m.accountName}',
                    style: RiderCashOutDialogStyles.methodDropdownText,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: onChanged,
            decoration: RiderCashOutDialogStyles.inputDecoration(),
          ),
      ],
    );
  }
}
