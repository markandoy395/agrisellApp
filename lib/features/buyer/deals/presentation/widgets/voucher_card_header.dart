import 'package:agresell_app/features/buyer/deals/presentation/styles/voucher_card_header_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import '../styles/voucher_card_styles.dart';

class VoucherCardHeader extends StatelessWidget {
  const VoucherCardHeader({required this.voucher, super.key});

  final DealVoucher voucher;

  @override
  Widget build(BuildContext context) {
    final isFarmer = voucher.isFarmerDeal;

    return Container(
      padding: VoucherCardStyles.headerPadding,
      decoration: VoucherCardHeaderStyles.containerDecoration(isFarmer),
      child: Row(
        children: [
          Container(
            padding: VoucherCardStyles.discountBadgePadding,
            decoration: VoucherCardStyles.discountBadgeDecoration,
            child: Text(
              voucher.discountLabel,
              style: VoucherCardStyles.discountBadgeTextStyle,
            ),
          ),
          const SizedBox(width: 8),
          if (voucher.isNewUsersOnly)
            Container(
              padding: VoucherCardStyles.newUsersBadgePadding,
              decoration: VoucherCardStyles.newUsersBadgeDecoration,
              child: const Text(
                'NEW USERS',
                style: VoucherCardStyles.newUsersBadgeTextStyle,
              ),
            ),
          const Spacer(),
          if (isFarmer && voucher.farmName != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.agriculture_rounded,
                  size: VoucherCardStyles.farmIconSize,
                  color: VoucherCardStyles.farmIconColor,
                ),
                const SizedBox(width: 4),
                Text(
                  voucher.farmName!,
                  style: VoucherCardStyles.farmNameTextStyle,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
