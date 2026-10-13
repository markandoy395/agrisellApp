import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';

class RiderEarningGuide extends StatelessWidget {
  const RiderEarningGuide({this.onOpenEarnings, super.key});

  final VoidCallback? onOpenEarnings;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'How you earn',
          style: SharedPresentationStyles.subtitleExtraBold,
        ),
        const SizedBox(height: 8),
        const Text(
          'Earn the agreed delivery fee for each completed delivery.',
          style: SharedPresentationStyles.caption,
        ),
        const Material(
          color: Colors.transparent,
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: Text('Fees, completion and payout'),
            children: [
              Text(
                '1. Check the estimated earning before accepting. If a fee is '
                'not set, ask the farmer to confirm it first.\n\n'
                '2. Complete pickup and delivery, including the required proof. '
                'Accepting an order alone does not earn the delivery fee.\n\n'
                '3. Check Earnings for the recorded amount. Approved adjustments '
                'and deductions can change your final pay.\n\n'
                '4. Pending means payout is outstanding. Paid means a payout has '
                'been recorded. Set up a payout method before requesting cash out.\n\n'
                'Cash collected for the products belongs to the farmer and must '
                'be remitted as instructed. It is separate from your delivery pay.',
                style: SharedPresentationStyles.caption,
              ),
            ],
          ),
        ),
        if (onOpenEarnings != null)
          TextButton.icon(
            onPressed: onOpenEarnings,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('View earnings'),
          ),
      ],
    ),
  );
}
