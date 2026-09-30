part of 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';

class _CheckoutVoucherPanel extends StatelessWidget {
  const _CheckoutVoucherPanel({
    required this.controller,
    required this.appliedVoucher,
    required this.isValidating,
    required this.errorMessage,
    required this.onApply,
    required this.onRemove,
    this.onBrowseVouchers,
  });

  final TextEditingController controller;
  final AppliedVoucher? appliedVoucher;
  final bool isValidating;
  final String? errorMessage;
  final VoidCallback onApply;
  final VoidCallback onRemove;
  final VoidCallback? onBrowseVouchers;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AgrisellColors.forestSoft,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: AgrisellColors.authGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voucher / Promo Code',
                        style: TextStyle(
                          color: AgrisellColors.brandBlack,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Apply a promo code to receive a discount',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onBrowseVouchers != null && appliedVoucher == null)
                  TextButton.icon(
                    onPressed: onBrowseVouchers,
                    style: TextButton.styleFrom(
                      foregroundColor: AgrisellColors.authGreen,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.wallet_giftcard_rounded, size: 16),
                    label: const Text(
                      'Browse',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (appliedVoucher != null)
              _AppliedVoucherView(
                voucher: appliedVoucher!,
                onRemove: onRemove,
              )
            else
              _VoucherInputView(
                controller: controller,
                isValidating: isValidating,
                errorMessage: errorMessage,
                onApply: onApply,
              ),
          ],
        ),
      ),
    );
  }
}

class _AppliedVoucherView extends StatelessWidget {
  const _AppliedVoucherView({
    required this.voucher,
    required this.onRemove,
  });

  final AppliedVoucher voucher;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AgrisellColors.forestSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AgrisellColors.authGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AgrisellColors.authGreen,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      voucher.code,
                      style: const TextStyle(
                        color: AgrisellColors.brandBlack,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AgrisellColors.authGreen,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        voucher.discountLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '-${formatBasketPeso(voucher.discountAmount)} off applied (${voucher.name})',
                  style: const TextStyle(
                    color: AgrisellColors.authGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AgrisellColors.mutedText,
            ),
            tooltip: 'Remove voucher',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _VoucherInputView extends StatelessWidget {
  const _VoucherInputView({
    required this.controller,
    required this.isValidating,
    required this.errorMessage,
    required this.onApply,
  });

  final TextEditingController controller;
  final bool isValidating;
  final String? errorMessage;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 38,
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g. HARVEST20)',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AgrisellColors.mutedText,
                    ),
                    filled: true,
                    fillColor: AgrisellColors.homeBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AgrisellColors.borderLine),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: AgrisellColors.borderLine),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: AgrisellColors.authGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onSubmitted: (_) => onApply(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: isValidating ? null : onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AgrisellColors.authGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: isValidating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Apply',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (errorMessage != null && errorMessage!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 14,
                color: AgrisellColors.statusRedText,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: AgrisellColors.statusRedText,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
