import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import '../utils/farmer_payout_filter.dart';
import 'payout_list_view.dart';
import 'payout_metrics_header.dart';

class PayoutHistoryBody extends StatelessWidget {
  const PayoutHistoryBody({
    required this.payouts,
    required this.cashOutRequests,
    required this.tabController,
    required this.onCashOut,
    required this.onRefresh,
    super.key,
  });

  final List<FarmerPayout> payouts;
  final List<FarmerCashOutRequest> cashOutRequests;
  final TabController tabController;
  final VoidCallback onCashOut;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final summary = FarmerPayoutSummary.fromPayouts(payouts);

    return Column(
      children: [
        PayoutMetricsHeader(summary: summary, onCashOut: onCashOut),
        Container(
          color: PayoutSurfaceStyles.white,
          child: TabBar(
            controller: tabController,
            indicatorColor: AgrisellColors.authGreen,
            indicatorWeight: PayoutLayoutStyles.tabIndicatorWeight,
            labelColor: AgrisellColors.authGreen,
            unselectedLabelColor: AgrisellColors.mutedText,
            labelStyle: PayoutTextStyles.tabLabel,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Paid'),
              Tab(text: 'Pending'),
              Tab(text: 'Failed'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              for (final filter in FarmerPayoutFilter.values)
                PayoutListView(
                  payouts: filter.filterPayouts(payouts),
                  cashOutRequests: filter.filterCashOutRequests(
                    cashOutRequests,
                  ),
                  filter: filter,
                  onRefresh: onRefresh,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
