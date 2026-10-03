import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/deals/domain/deal_voucher.dart';
import 'package:agresell_app/features/buyer/deals/presentation/styles/deals_and_promos_screen_styles.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/deals_empty_view.dart';
import 'package:agresell_app/features/buyer/deals/presentation/widgets/voucher_card.dart';

class DealsVoucherListView extends StatelessWidget {
  const DealsVoucherListView({
    required this.items,
    required this.onShopProducts,
    required this.onApply,
    super.key,
  });

  final List<DealVoucher> items;
  final ValueChanged<DealVoucher> onShopProducts;
  final ValueChanged<DealVoucher>? onApply;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const DealsEmptyView();
    }

    return ListView.separated(
      padding: DealsAndPromosScreenStyles.listPadding,
      itemCount: items.length,
      separatorBuilder: (_, _) => DealsAndPromosScreenStyles.listSeparator,
      itemBuilder: (context, index) {
        final voucher = items[index];
        return VoucherCard(
          voucher: voucher,
          onShopProducts: voucher.productCount > 0
              ? () => onShopProducts(voucher)
              : null,
          onApply: onApply != null ? () => onApply!(voucher) : null,
        );
      },
    );
  }
}
