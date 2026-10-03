import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';

import '../styles/rider_withdrawal_control_styles.dart';
import '../styles/rider_withdrawal_styles.dart';

class RiderWithdrawalMethodTile extends StatelessWidget {
  const RiderWithdrawalMethodTile({
    required this.method,
    required this.onDelete,
    super.key,
  });

  final RiderWithdrawalMethod method;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: RiderWithdrawalStyles.tilePadding,
      decoration: method.isDefault
          ? RiderWithdrawalControlStyles.defaultMethod
          : RiderWithdrawalControlStyles.regularMethod,
      child: Row(
        children: [
          Container(
            padding: RiderWithdrawalStyles.iconPadding,
            decoration: method.isDefault
                ? RiderWithdrawalControlStyles.defaultMethodIcon
                : RiderWithdrawalControlStyles.regularMethodIcon,
            child: Icon(
              method.isGcash
                  ? Icons.phone_android_rounded
                  : Icons.account_balance_rounded,
              color: method.isDefault
                  ? RiderWithdrawalControlStyles.selectedIconColor
                  : RiderWithdrawalControlStyles.unselectedIconColor,
              size: RiderWithdrawalStyles.actionIconSize,
            ),
          ),
          const SizedBox(width: RiderWithdrawalStyles.controlGap),
          Expanded(
            child: Column(
              crossAxisAlignment: RiderWithdrawalStyles.alignStart,
              children: [
                Row(
                  children: [
                    Text(
                      method.methodLabel,
                      style: RiderWithdrawalStyles.methodLabel,
                    ),
                    if (method.isDefault) ...[
                      const SizedBox(width: RiderWithdrawalStyles.inlineGap),
                      Container(
                        padding: RiderWithdrawalStyles.defaultPadding,
                        decoration: RiderWithdrawalStyles.defaultBadge,
                        child: const Text(
                          'DEFAULT',
                          style: RiderWithdrawalStyles.defaultLabel,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: RiderWithdrawalStyles.tinyGap),
                Text(
                  '${method.accountName} · ${method.accountNumber}',
                  style: RiderWithdrawalStyles.accountDetails,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Remove',
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: RiderWithdrawalStyles.actionIconSize,
              color: RiderWithdrawalStyles.deleteColor,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
