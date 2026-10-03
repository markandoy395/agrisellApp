import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import '../styles/voucher_card_styles.dart';
import 'voucher_card_actions.dart';
import 'voucher_card_header.dart';

class VoucherCard extends StatelessWidget {
  const VoucherCard({
    required this.voucher,
    this.onShopProducts,
    this.onApply,
    this.isEligibleForCart,
    this.ineligibleReason,
    this.potentialSavings,
    super.key,
  });

  final DealVoucher voucher;
  final VoidCallback? onShopProducts;
  final VoidCallback? onApply;
  final bool? isEligibleForCart;
  final String? ineligibleReason;
  final double? potentialSavings;

  void _copyCode(BuildContext context) {
    if (!voucher.hasCode) return;
    Clipboard.setData(ClipboardData(text: voucher.code!));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showAppSnackBar(
        SnackBar(
          content: Text('Voucher code "${voucher.code}" copied to clipboard!'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isEligibleActive = onApply != null && isEligibleForCart == true;

    return Container(
      decoration: VoucherCardStyles.cardDecoration(
        isEligibleActive: isEligibleActive,
      ),
      child: ClipRRect(
        borderRadius: VoucherCardStyles.cardRadius,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            VoucherCardHeader(voucher: voucher),
            Padding(
              padding: VoucherCardStyles.bodyPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.name,
                    style: VoucherCardStyles.titleTextStyle,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: VoucherCardStyles.expiryIconSize,
                            color: VoucherCardStyles.expiryIconColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            voucher.formattedExpiry,
                            style: VoucherCardStyles.expiryTextStyle,
                          ),
                        ],
                      ),
                      if (voucher.productCount > 0) ...[
                        const Text(
                          '\u2022',
                          style: VoucherCardStyles.bulletTextStyle,
                        ),
                        Text(
                          '${voucher.productCount} ${voucher.productCount == 1 ? 'product' : 'products'}',
                          style: VoucherCardStyles.productCountTextStyle,
                        ),
                      ],
                    ],
                  ),
                  if (potentialSavings != null && potentialSavings! > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: VoucherCardStyles.eligibleBadgePadding,
                      decoration: VoucherCardStyles.eligibleBadgeDecoration,
                      child: Text(
                        'Eligible! Save \u20b1${potentialSavings!.toStringAsFixed(2)} on your cart',
                        style: VoucherCardStyles.eligibleBadgeTextStyle,
                      ),
                    ),
                  ] else if (ineligibleReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      ineligibleReason!,
                      style: VoucherCardStyles.ineligibleTextStyle,
                    ),
                  ],
                  const SizedBox(height: 12),
                  VoucherCardActions(
                    voucher: voucher,
                    onCopyCode: () => _copyCode(context),
                    onShopProducts: onShopProducts,
                    onApply: onApply,
                    isEligibleForCart: isEligibleForCart,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
