import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';

import '../styles/payout_layout_styles.dart';
import '../utils/farmer_payout_filter.dart';
import 'farmer_cash_out_request_card.dart';
import 'farmer_payout_card.dart';
import 'payout_empty_state.dart';

class PayoutListView extends StatelessWidget {
  const PayoutListView({
    required this.payouts,
    required this.cashOutRequests,
    required this.filter,
    required this.onRefresh,
  });

  final List<FarmerPayout> payouts;
  final List<FarmerCashOutRequest> cashOutRequests;
  final FarmerPayoutFilter filter;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final totalItems = payouts.length + cashOutRequests.length;

    if (totalItems == 0) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: PayoutLayoutStyles.emptyStateTopSpace(context)),
            PayoutEmptyState(filter: filter),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: PayoutLayoutStyles.listPadding,
        children: [
          if (cashOutRequests.isNotEmpty) ...[
            for (final request in cashOutRequests) ...[
              FarmerCashOutRequestCard(request: request),
              const SizedBox(height: PayoutLayoutStyles.sectionGap),
            ],
          ],
          for (final payout in payouts) ...[
            FarmerPayoutCard(payout: payout),
            const SizedBox(height: PayoutLayoutStyles.sectionGap),
          ],
        ],
      ),
    );
  }
}
