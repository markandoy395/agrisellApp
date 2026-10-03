part of 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';

class _RiderEarningsSnapshot extends StatelessWidget {
  const _RiderEarningsSnapshot({required this.amount, this.pendingAmount});

  final double amount;
  final double? pendingAmount;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    padding: RiderDashboardContentStyles.cardPadding,
    child: Row(
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: RiderDashboardContentStyles.earningsIconDecoration,
          child: const Icon(
            Icons.account_balance_wallet_outlined,
            color: AgrisellColors.authGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHP ${amount.toStringAsFixed(2)}',
                style: RiderDashboardContentStyles.earningsAmountStyle,
              ),
              const SizedBox(height: 3),
              const Text(
                'Estimated earnings today',
                style: RiderDashboardContentStyles.earningsLabelStyle,
              ),
              if (pendingAmount != null) ...[
                const SizedBox(height: 3),
                Text(
                  'PHP ${pendingAmount!.toStringAsFixed(2)} pending',
                  style: RiderDashboardContentStyles.earningsPendingStyle,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class _RiderSafetySupportCard extends StatelessWidget {
  const _RiderSafetySupportCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: RiderSurfaceCard(
        padding: RiderDashboardContentStyles.cardPadding,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: RiderDashboardContentStyles.safetyIconDecoration,
              child: const Icon(
                Icons.shield_outlined,
                color: AgrisellColors.statusBlueText,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Safety and support',
                    style: RiderDashboardContentStyles.safetyTitleStyle,
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Get help, report an issue, or review safety tools.',
                    style: RiderDashboardContentStyles.safetySubtitleStyle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AgrisellColors.mutedText,
            ),
          ],
        ),
      ),
    );
  }
}
