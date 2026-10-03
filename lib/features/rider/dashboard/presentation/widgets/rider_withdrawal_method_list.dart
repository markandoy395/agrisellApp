import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';

import '../styles/rider_withdrawal_control_styles.dart';
import '../styles/rider_withdrawal_styles.dart';
import 'rider_withdrawal_method_tile.dart';

class RiderWithdrawalMethodList extends StatelessWidget {
  const RiderWithdrawalMethodList({
    required this.methods,
    required this.onDelete,
    required this.onAdd,
    super.key,
  });

  final List<RiderWithdrawalMethod> methods;
  final ValueChanged<String> onDelete;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: RiderWithdrawalStyles.alignStart,
      children: [
        if (methods.isEmpty)
          Container(
            padding: RiderWithdrawalStyles.emptyPadding,
            decoration: RiderWithdrawalStyles.emptyPanel,
            child: const Center(
              child: Text(
                'No withdrawal methods saved yet.\nAdd GCash or a bank account to receive your payouts.',
                textAlign: RiderWithdrawalStyles.centeredText,
                style: RiderWithdrawalStyles.accountDetails,
              ),
            ),
          )
        else
          for (final method in methods) ...[
            RiderWithdrawalMethodTile(
              method: method,
              onDelete: () => onDelete(method.methodId),
            ),
            const SizedBox(height: RiderWithdrawalStyles.itemGap),
          ],
        const SizedBox(height: RiderWithdrawalStyles.sectionGap),
        SizedBox(
          width: RiderWithdrawalStyles.fullWidth,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_rounded,
              size: RiderWithdrawalStyles.typeIconSize,
            ),
            label: const Text('Add Withdrawal Method'),
            style: RiderWithdrawalControlStyles.addButton,
          ),
        ),
      ],
    );
  }
}
