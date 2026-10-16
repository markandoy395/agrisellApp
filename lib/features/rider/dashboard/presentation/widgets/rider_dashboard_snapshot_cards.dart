part of 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_dashboard_screen.dart';

class _RiderEarningsSnapshot extends StatelessWidget {
  const _RiderEarningsSnapshot({
    required this.amount,
    this.pendingAmount,
    required this.online,
    required this.onTap,
  });

  final bool online;
  final VoidCallback onTap;

  final double amount;
  final double? pendingAmount;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      decoration: RiderHomeDesignStyles.earnings(online),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: online
                ? RiderHomeDesignStyles.green
                : RiderHomeDesignStyles.muted,
            size: 32,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHP ${amount.toStringAsFixed(2)}',
                  style: RiderHomeDesignStyles.amount,
                ),
                const SizedBox(height: 3),
                const Text(
                  'Estimated earnings today',
                  style: RiderDashboardContentStyles.earningsLabelStyle,
                ),
                if (pendingAmount != null && pendingAmount! > 0) ...[
                  const SizedBox(height: 3),
                  Text(
                    'PHP ${pendingAmount!.toStringAsFixed(2)} pending',
                    style: RiderDashboardContentStyles.earningsPendingStyle,
                  ),
                ],
                if (pendingAmount == 0)
                  const Text(
                    'No pending earnings',
                    style: RiderHomeDesignStyles.caption,
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: RiderHomeDesignStyles.green,
          ),
        ],
      ),
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
        decoration: RiderHomeDesignStyles.card,
        padding: RiderDashboardContentStyles.cardPadding,
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: RiderDashboardContentStyles.safetyIconDecoration,
              child: const Icon(
                Icons.shield_rounded,
                color: RiderHomeDesignStyles.green,
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
