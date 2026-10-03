import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import '../styles/voucher_card_styles.dart';

class VoucherCardActions extends StatelessWidget {
  const VoucherCardActions({
    required this.voucher,
    required this.onCopyCode,
    this.onShopProducts,
    this.onApply,
    this.isEligibleForCart,
    super.key,
  });

  final DealVoucher voucher;
  final VoidCallback onCopyCode;
  final VoidCallback? onShopProducts;
  final VoidCallback? onApply;
  final bool? isEligibleForCart;

  @override
  Widget build(BuildContext context) {
    final hasCode = voucher.hasCode;

    return Row(
      children: [
        if (hasCode) ...[
          InkWell(
            onTap: onCopyCode,
            borderRadius: VoucherCardStyles.codeBoxRadius,
            child: Container(
              padding: VoucherCardStyles.codeBoxPadding,
              decoration: VoucherCardStyles.codeBoxDecoration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    voucher.code!,
                    style: VoucherCardStyles.codeTextStyle,
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.copy_rounded,
                    size: VoucherCardStyles.copyIconSize,
                    color: VoucherCardStyles.copyIconColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        const Spacer(),
        if (onShopProducts != null && voucher.productCount > 0)
          OutlinedButton(
            onPressed: onShopProducts,
            style: VoucherCardStyles.shopItemsButtonStyle,
            child: const Text(
              'Shop items',
              style: VoucherCardStyles.shopItemsButtonTextStyle,
            ),
          ),
        if (onApply != null) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isEligibleForCart == false ? null : onApply,
            style: VoucherCardStyles.applyButtonStyle,
            child: const Text(
              'Apply',
              style: VoucherCardStyles.applyButtonTextStyle,
            ),
          ),
        ],
      ],
    );
  }
}
