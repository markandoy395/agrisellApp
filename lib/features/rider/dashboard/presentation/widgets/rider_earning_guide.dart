import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../styles/rider_home_design_styles.dart';
import '../styles/rider_reference_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import '../../../presentation/widgets/rider_page_widgets.dart';

class RiderEarningGuide extends StatelessWidget {
  const RiderEarningGuide({this.onOpenEarnings, super.key});

  final VoidCallback? onOpenEarnings;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    decoration: RiderHomeDesignStyles.card,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Icon(
              Icons.monetization_on_rounded,
              color: AgrisellColors.accentOrange,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How you earn', style: RiderHomeDesignStyles.title),
                  SizedBox(height: 4),
                  Text(
                    'Earn the agreed delivery fee for each completed delivery.',
                    style: RiderReferenceStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: RiderReferenceStyles.listRow,
          child: const Material(
            color: Colors.transparent,
            child: ExpansionTile(
              dense: true,
              tilePadding: EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: EdgeInsets.all(12),
              title: Text(
                'Fees, completion and payout',
                style: RiderReferenceStyles.body,
              ),
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
        ),
        const SizedBox(height: 8),
        if (onOpenEarnings != null)
          TextButton.icon(
            style: RiderHomeDesignStyles.secondaryButton,
            onPressed: onOpenEarnings,
            icon: const Icon(Icons.account_balance_wallet_outlined),
            label: const Text('View earnings'),
          ),
      ],
    ),
  );
}
