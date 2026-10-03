import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';

void main() {
  final items = [_item('1', 20, 2), _item('2', 30, 1)];

  double discount(String type, double value, {Set<int> ids = const {}}) =>
      CheckoutVoucherService.calculateDiscount(
        items: items,
        applicableIds: ids,
        discountType: type,
        discountValue: value,
      );

  test('percentage discounts apply only to eligible commodities', () {
    expect(discount('percentage', 10, ids: {1}), 4);
    expect(discount('percentage', 10), 7);
    expect(discount('percentage', 10, ids: {99}), 0);
  });

  test('amount discounts are capped at the eligible subtotal', () {
    expect(discount('amount', 100, ids: {1}), 40);
    expect(discount('amount', 5), 5);
  });

  test('sale prices discount each unit without increasing its price', () {
    expect(discount('sale_price', 10), 40);
    expect(discount('sale_price', 25), 5);
    expect(discount('sale_price', 40), 0);
  });

  test('discount totals retain rounding to two decimal places', () {
    expect(discount('percentage', 33.333), 23.33);
  });

  test(
    'custom validators receive normalized codes and original items',
    () async {
      final service = CheckoutVoucherService(
        customValidator: (code, selected) async {
          expect(code, 'HARVEST');
          expect(identical(selected, items), isTrue);
          return const AppliedVoucher(
            saleId: '1',
            name: 'Harvest',
            code: 'HARVEST',
            discountType: 'amount',
            discountValue: 5,
            targetUserGroup: 'all_users',
            discountAmount: 5,
            applicableCommodityIds: {},
          );
        },
      );
      expect(
        (await service.validateVoucher(code: ' harvest ', items: items)).code,
        'HARVEST',
      );
    },
  );
}

BasketCartItem _item(String id, double price, int quantity) => BasketCartItem(
  productId: id,
  productName: 'Produce',
  image: '',
  sellerName: 'Farmer',
  sellerLocation: 'Farm',
  harvestDate: 'Today',
  availableWeight: '10 kg',
  priceLabel: 'Price',
  pricePerKg: price,
  unit: 'kg',
  quantity: quantity,
  isSelected: true,
);
