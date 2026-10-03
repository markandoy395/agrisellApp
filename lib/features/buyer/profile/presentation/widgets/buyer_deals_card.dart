import 'package:agresell_app/features/buyer/profile/presentation/styles/buyer_deals_card_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/buyer/deals/presentation/screens/deals_and_promos_screen.dart';

class BuyerDealsCard extends StatelessWidget {
  const BuyerDealsCard({super.key});

  void _openDeals(BuildContext context) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const DealsAndPromosScreen()),
    );
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => _openDeals(context),
    child: Container(
      decoration: BuyerDealsCardStyles.containerDecoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _openDeals(context),
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
                  decoration: BuyerDealsCardStyles.containerDecoration2,
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Voucher Wallet & Deals',
                    style: BuyerDealsCardStyles.voucherWalletDealsText,
                  ),
                ),
                const SizedBox(width: 10),
                // Arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BuyerDealsCardStyles.containerDecoration3,
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
