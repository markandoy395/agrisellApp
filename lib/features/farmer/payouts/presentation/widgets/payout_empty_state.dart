import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/payout_layout_styles.dart';
import '../styles/payout_surface_styles.dart';
import '../styles/payout_text_styles.dart';
import '../utils/farmer_payout_filter.dart';

class PayoutEmptyState extends StatelessWidget {
  const PayoutEmptyState({required this.filter, super.key});

  final FarmerPayoutFilter filter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: PayoutLayoutStyles.shrinkWrap,
        children: [
          Container(
            width: PayoutLayoutStyles.emptyIconSize,
            height: PayoutLayoutStyles.emptyIconSize,
            decoration: PayoutSurfaceStyles.emptyIcon,
            child: const Icon(
              Icons.payments_outlined,
              size: PayoutLayoutStyles.emptyIconGlyphSize,
              color: AgrisellColors.mutedText,
            ),
          ),
          const SizedBox(height: PayoutLayoutStyles.sectionGap),
          Text(switch (filter) {
            FarmerPayoutFilter.paid => 'No paid disbursements yet',
            FarmerPayoutFilter.pending => 'No pending payouts',
            FarmerPayoutFilter.failed => 'No failed payouts',
            FarmerPayoutFilter.all => 'No payout records found',
          }, style: PayoutTextStyles.heading),
          const SizedBox(height: PayoutLayoutStyles.smallGap),
          const Text(
            'Disbursements and cash-out requests will be listed here.',
            style: PayoutTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
