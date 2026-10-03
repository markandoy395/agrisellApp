import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/rider_cash_out_dialog_styles.dart';

class RiderCashOutHeader extends StatelessWidget {
  const RiderCashOutHeader({
    required this.onClose,
    super.key,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: RiderCashOutDialogStyles.headerIconPadding,
                  decoration: RiderCashOutDialogStyles.headerIconDecoration,
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AgrisellColors.authGreen,
                    size: RiderCashOutDialogStyles.headerIconSize,
                  ),
                ),
                const SizedBox(width: RiderCashOutDialogStyles.headerGap),
                const Text(
                  'Cash Out Earnings',
                  style: RiderCashOutDialogStyles.headerTitle,
                ),
              ],
            ),
            IconButton(
              icon: const Icon(
                Icons.close_rounded,
                size: RiderCashOutDialogStyles.headerCloseSize,
              ),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: RiderCashOutDialogStyles.subtitleGap),
        const Text(
          'Submit a withdrawal request to transfer earnings to your account.',
          style: RiderCashOutDialogStyles.headerSubtitle,
        ),
      ],
    );
  }
}
