import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/home/presentation/styles/home_product_scroll_view_styles.dart';

class HomeDealsQuickBanner extends StatelessWidget {
  const HomeDealsQuickBanner({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: HomeProductScrollViewStyles.dealsBorderRadius,
      child: Container(
        padding: HomeProductScrollViewStyles.dealsPadding,
        decoration: HomeProductScrollViewStyles.dealsDecoration,
        child: Row(
          children: [
            Container(
              padding: HomeProductScrollViewStyles.dealsIconContainerPadding,
              decoration:
                  HomeProductScrollViewStyles.dealsIconContainerDecoration,
              child: const Icon(
                Icons.local_offer_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deals & Voucher Wallet',
                    style: HomeProductScrollViewStyles.dealsTitleStyle,
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Browse active promos, vouchers & limited discounts',
                    style: HomeProductScrollViewStyles.dealsSubtitleStyle,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white70,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
