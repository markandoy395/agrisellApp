import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';

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
    final hasCode = voucher.hasCode;
    final isFarmer = voucher.isFarmerDeal;

    return Container(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: onApply != null && isEligibleForCart == true
              ? AgrisellColors.authGreen
              : AgrisellColors.borderLine,
          width: onApply != null && isEligibleForCart == true ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isFarmer
                    ? const Color(0xFFE8F5E9)
                    : AgrisellColors.forestSoft,
                border: Border(
                  bottom: BorderSide(
                    color: AgrisellColors.borderLine.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AgrisellColors.authGreen,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      voucher.discountLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (voucher.isNewUsersOnly)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9800).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: const Color(0xFFFF9800).withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'NEW USERS',
                        style: TextStyle(
                          color: Color(0xFFE65100),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  const Spacer(),
                  if (isFarmer && voucher.farmName != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.agriculture_rounded,
                          size: 14,
                          color: AgrisellColors.authGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          voucher.farmName!,
                          style: const TextStyle(
                            color: AgrisellColors.authGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.name,
                    style: const TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
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
                            size: 13,
                            color: AgrisellColors.mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            voucher.formattedExpiry,
                            style: const TextStyle(
                              color: AgrisellColors.mutedText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (voucher.productCount > 0) ...[
                        const Text(
                          '\u2022',
                          style: TextStyle(color: AgrisellColors.mutedText),
                        ),
                        Text(
                          '${voucher.productCount} ${voucher.productCount == 1 ? 'product' : 'products'}',
                          style: const TextStyle(
                            color: AgrisellColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (potentialSavings != null && potentialSavings! > 0) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AgrisellColors.forestSoft,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Eligible! Save \u20b1${potentialSavings!.toStringAsFixed(2)} on your cart',
                        style: const TextStyle(
                          color: AgrisellColors.authGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ] else if (ineligibleReason != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      ineligibleReason!,
                      style: const TextStyle(
                        color: AgrisellColors.statusRedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (hasCode) ...[
                        InkWell(
                          onTap: () => _copyCode(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AgrisellColors.homeBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AgrisellColors.borderLine,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  voucher.code!,
                                  style: const TextStyle(
                                    color: AgrisellColors.brandBlack,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: AgrisellColors.authGreen,
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
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AgrisellColors.authGreen,
                            side: const BorderSide(
                              color: AgrisellColors.authGreen,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Shop items',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (onApply != null) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isEligibleForCart == false ? null : onApply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AgrisellColors.authGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
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
