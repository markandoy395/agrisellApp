import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';

class RiderEarningsHeaderActions extends StatelessWidget {
  const RiderEarningsHeaderActions({
    required this.onExportCsv,
    required this.onOpenWithdrawalMethods,
    required this.onOpenRatings,
    required this.onClose,
    super.key,
  });

  final VoidCallback onExportCsv;
  final VoidCallback onOpenWithdrawalMethods;
  final VoidCallback onOpenRatings;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Export CSV',
          onPressed: onExportCsv,
          icon: const Icon(
            Icons.file_download_outlined,
            color: RiderEarningsStyles.headerIconColor,
          ),
        ),
        IconButton(
          tooltip: 'Withdrawal methods',
          onPressed: onOpenWithdrawalMethods,
          icon: const Icon(
            Icons.account_balance_wallet_outlined,
            color: RiderEarningsStyles.headerIconColor,
          ),
        ),
        IconButton(
          tooltip: 'View ratings',
          onPressed: onOpenRatings,
          icon: const Icon(
            Icons.star_outline_rounded,
            color: RiderEarningsStyles.headerIconColor,
          ),
        ),
        IconButton(
          tooltip: 'Close',
          onPressed: onClose,
          icon: const Icon(
            Icons.close_rounded,
            color: RiderEarningsStyles.headerIconColor,
          ),
        ),
      ],
    );
  }
}
