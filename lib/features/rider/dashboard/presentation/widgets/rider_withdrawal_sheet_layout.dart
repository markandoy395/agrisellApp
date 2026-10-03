import 'package:flutter/material.dart';

import '../styles/rider_withdrawal_styles.dart';

class RiderWithdrawalSheetLayout extends StatelessWidget {
  const RiderWithdrawalSheetLayout({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: RiderWithdrawalStyles.keyboardPadding(context),
        child: SingleChildScrollView(
          padding: RiderWithdrawalStyles.sheetPadding,
          child: Column(
            mainAxisSize: RiderWithdrawalStyles.shrinkWrap,
            crossAxisAlignment: RiderWithdrawalStyles.alignStart,
            children: [
              Center(
                child: Container(
                  width: RiderWithdrawalStyles.dragHandleWidth,
                  height: RiderWithdrawalStyles.dragHandleHeight,
                  decoration: RiderWithdrawalStyles.dragHandle,
                ),
              ),
              const SizedBox(height: RiderWithdrawalStyles.sectionGap),
              Row(
                mainAxisAlignment: RiderWithdrawalStyles.spaceBetween,
                children: [
                  const Text(
                    'Withdrawal Methods',
                    style: RiderWithdrawalStyles.title,
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: RiderWithdrawalStyles.actionIconSize,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Text(
                'Manage your GCash and bank accounts for earnings payouts.',
                style: RiderWithdrawalStyles.subtitle,
              ),
              const SizedBox(height: RiderWithdrawalStyles.sectionGap),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
