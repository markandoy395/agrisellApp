import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_stats_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/payouts/data/farmer_payout_repository.dart';
import 'package:agresell_app/features/farmer/payouts/presentation/screens/farmer_payout_history_screen.dart';

class FarmerStatsCard extends StatelessWidget {
  const FarmerStatsCard({this.repository, super.key});

  final FarmerPayoutRepository? repository;

  void _openPayoutHistory(BuildContext context) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => FarmerPayoutHistoryScreen(repository: repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _openPayoutHistory(context),
    child: Container(
      decoration: FarmerStatsCardStyles.containerDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _openPayoutHistory(context),
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
                  decoration: FarmerStatsCardStyles.containerDecoration2,
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                const Expanded(
                  child: Text(
                    'Payouts & Disbursements',
                    style: FarmerStatsCardStyles.payoutsDisbursementsText,
                  ),
                ),
                const SizedBox(width: 10),
                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: FarmerStatsCardStyles.containerDecoration3,
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
