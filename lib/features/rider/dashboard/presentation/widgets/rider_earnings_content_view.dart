import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_earnings_styles.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_history.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earnings_widgets.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_state_cards.dart';

class RiderEarningsContentView extends StatelessWidget {
  const RiderEarningsContentView({
    required this.controller,
    required this.onRetry,
    required this.onCashOut,
    required this.onManageMethods,
    required this.onOpenDelivery,
    super.key,
  });

  final RiderAnalyticsController controller;
  final VoidCallback onRetry;
  final VoidCallback onCashOut;
  final VoidCallback onManageMethods;
  final ValueChanged<String> onOpenDelivery;

  @override
  Widget build(BuildContext context) {
    return switch (controller.earningsState) {
      RiderAnalyticsLoadState.idle ||
      RiderAnalyticsLoadState.loading => const Column(
        children: [
          RiderLoadingStateCard(
            title: 'Loading earnings',
            message: 'Retrieving rider earnings and payout details.',
          ),
        ],
      ),
      RiderAnalyticsLoadState.error => Column(
        children: [
          RiderErrorStateCard(
            title: 'Earnings unavailable',
            message: controller.earningsError ?? 'Please try again.',
            retryLabel: 'Retry',
            onRetry: onRetry,
          ),
        ],
      ),
      RiderAnalyticsLoadState.ready when !controller.earnings.hasData => Column(
        children: [
          RiderEarningsSummaryCard(
            summary: controller.earnings.summary,
            onCashOut: onCashOut,
            onManageMethods: onManageMethods,
          ),
          RiderEarningsStyles.cardSpacing,
          const RiderEmptyStateCard(
            title: 'No earnings yet',
            message:
                'Completed delivery fees, incentives, bonuses, deductions, and payout status will appear here.',
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
      RiderAnalyticsLoadState.ready => Column(
        children: [
          RiderEarningsSummaryCard(
            summary: controller.earnings.summary,
            onCashOut: onCashOut,
            onManageMethods: onManageMethods,
          ),
          RiderEarningsStyles.cardSpacing,
          RiderEarningsBreakdownCard(summary: controller.earnings.summary),
          if (controller.earnings.entries.isNotEmpty) ...[
            RiderEarningsStyles.historySpacing,
            RiderEarningsHistory(
              entries: controller.earnings.entries,
              onOpenDelivery: onOpenDelivery,
            ),
          ],
        ],
      ),
    };
  }
}
