import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/deals/data/buyer_deals_repository.dart';
import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/voucher_card.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

class CheckoutVoucherPickerSheet extends StatefulWidget {
  const CheckoutVoucherPickerSheet({
    required this.cartItems,
    required this.onSelectVoucher,
    this.dealsRepository = const BuyerDealsRepository(),
    super.key,
  });

  final List<BasketCartItem> cartItems;
  final ValueChanged<DealVoucher> onSelectVoucher;
  final BuyerDealsRepository dealsRepository;

  @override
  State<CheckoutVoucherPickerSheet> createState() =>
      _CheckoutVoucherPickerSheetState();
}

class _CheckoutVoucherPickerSheetState
    extends State<CheckoutVoucherPickerSheet> {
  List<DealVoucher> _vouchers = const [];
  Map<int, double> _savingsMap = const {};
  Map<int, String?> _ineligibleReasonMap = const {};
  var _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    try {
      final allDeals = await widget.dealsRepository.loadActiveDeals();
      final vouchers = allDeals.where((d) => d.hasCode).toList(growable: false);

      final savings = <int, double>{};
      final reasons = <int, String?>{};

      for (final v in vouchers) {
        final applicableIds =
            await widget.dealsRepository.loadApplicableCommodityIds(v.saleId);

        final calculated = CheckoutVoucherService.calculateDiscount(
          items: widget.cartItems,
          applicableIds: applicableIds,
          discountType: v.discountType,
          discountValue: v.discountValue,
        );

        if (calculated > 0) {
          savings[v.saleId] = calculated;
        } else {
          reasons[v.saleId] =
              'No items in your cart are eligible for this voucher.';
        }
      }

      if (!mounted) return;
      setState(() {
        _vouchers = vouchers;
        _savingsMap = savings;
        _ineligibleReasonMap = reasons;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AgrisellColors.borderLine,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  color: AgrisellColors.authGreen,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Available Vouchers',
                    style: TextStyle(
                      color: AgrisellColors.brandBlack,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(
                        color: AgrisellColors.authGreen,
                      ),
                    ),
                  )
                : _vouchers.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(36),
                        child: Center(
                          child: Text(
                            'No vouchers available right now.',
                            style: TextStyle(
                              color: AgrisellColors.mutedText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        shrinkWrap: true,
                        itemCount: _vouchers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final voucher = _vouchers[index];
                          final savings = _savingsMap[voucher.saleId];
                          final reason = _ineligibleReasonMap[voucher.saleId];
                          final isEligible = savings != null && savings > 0;

                          return VoucherCard(
                            voucher: voucher,
                            isEligibleForCart: isEligible,
                            potentialSavings: savings,
                            ineligibleReason: reason,
                            onApply: () {
                              widget.onSelectVoucher(voucher);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
