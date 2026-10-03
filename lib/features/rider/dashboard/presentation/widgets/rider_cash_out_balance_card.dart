import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';
import '../styles/rider_cash_out_dialog_styles.dart';

class RiderCashOutBalanceCard extends StatelessWidget {
  const RiderCashOutBalanceCard({
    required this.availableEarnings,
    super.key,
  });

  final double availableEarnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: RiderCashOutDialogStyles.balancePadding,
      decoration: RiderCashOutDialogStyles.balanceCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available to Withdraw',
                  style: RiderCashOutDialogStyles.balanceLabel,
                ),
                Text(
                  'Net unwithdrawn earnings',
                  style: RiderCashOutDialogStyles.balanceSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: RiderCashOutDialogStyles.balanceContentGap),
          Text(
            formatRiderCurrency(availableEarnings),
            style: RiderCashOutDialogStyles.balanceValue,
          ),
        ],
      ),
    );
  }
}
