import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/cart/data/checkout_voucher_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_farmer_messenger.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_inventory_reconciler.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_order_submission.dart';
import 'package:agresell_app/features/buyer/cart/presentation/utils/checkout_price_calculator.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';

BasketCartItem _makeItem({
  required String id,
  required String name,
  required double price,
  int quantity = 1,
  bool hasSale = false,
  String? originalPriceLabel,
  int? farmId = 1,
  String sellerName = 'Farmer John',
  String sellerLocation = 'Bukidnon',
}) {
  return BasketCartItem(
    productId: id,
    productName: name,
    image: '',
    sellerName: sellerName,
    sellerLocation: sellerLocation,
    harvestDate: 'Today',
    availableWeight: '100 kg',
    priceLabel: '\u20B1$price',
    pricePerKg: price,
    unit: 'kg',
    quantity: quantity,
    isSelected: true,
    originalPriceLabel: originalPriceLabel,
    farmId: farmId,
  );
}

void main() {
  group('CheckoutPriceCalculator', () {
    test('parsePrice parses numbers and currency strings', () {
      expect(CheckoutPriceCalculator.parsePrice('\u20B11,250.50'), 1250.50);
      expect(CheckoutPriceCalculator.parsePrice('45.00'), 45.00);
      expect(CheckoutPriceCalculator.parsePrice('invalid'), 0.0);
    });

    test('calculateItemsSubtotal calculates regular and sale items', () {
      final items = [
        _makeItem(id: '1', name: 'Item 1', price: 50.0, quantity: 2),
        _makeItem(
          id: '2',
          name: 'Item 2',
          price: 30.0,
          quantity: 3,
          hasSale: true,
          originalPriceLabel: '\u20B140.00',
        ),
      ];
      // Item 1: 2 * 50 = 100
      // Item 2: 3 * 40 = 120 (from originalPriceLabel)
      // Total: 220.0
      expect(CheckoutPriceCalculator.calculateItemsSubtotal(items), 220.0);
    });

    test('calculateProductSaleDiscount calculates difference accurately', () {
      final items = [
        _makeItem(id: '1', name: 'Item 1', price: 50.0, quantity: 2),
        _makeItem(
          id: '2',
          name: 'Item 2',
          price: 30.0,
          quantity: 3,
          hasSale: true,
          originalPriceLabel: '\u20B140.00',
        ),
      ];
      // Item 2 discount: 3 * (40 - 30) = 30
      expect(CheckoutPriceCalculator.calculateProductSaleDiscount(items), 30.0);
    });

    test('calculateFinalTotal deducts voucher discount and clamps to 0', () {
      expect(
        CheckoutPriceCalculator.calculateFinalTotal(
          selectedTotal: 100.0,
          voucherDiscount: 20.0,
        ),
        80.0,
      );
      expect(
        CheckoutPriceCalculator.calculateFinalTotal(
          selectedTotal: 15.0,
          voucherDiscount: 20.0,
        ),
        0.0,
      );
    });

    test('applyVoucherDiscounts percentage voucher', () {
      final items = [
        _makeItem(id: '10', name: 'Tomatoes', price: 100.0, quantity: 1),
      ];
      const voucher = AppliedVoucher(
        saleId: 's1',
        name: '20% off',
        code: 'SAVE20',
        discountType: 'percentage',
        discountValue: 20,
        targetUserGroup: 'all',
        discountAmount: 20,
        applicableCommodityIds: {},
      );

      final result = CheckoutPriceCalculator.applyVoucherDiscounts(
        items: items,
        selectedTotal: 100.0,
        appliedVoucher: voucher,
      );

      expect(result.first.pricePerKg, 80.0);
    });

    test('applyVoucherDiscounts sale_price voucher', () {
      final items = [
        _makeItem(id: '10', name: 'Tomatoes', price: 100.0, quantity: 1),
      ];
      const voucher = AppliedVoucher(
        saleId: 's1',
        name: 'Fixed Sale',
        code: 'SALE50',
        discountType: 'sale_price',
        discountValue: 50,
        targetUserGroup: 'all',
        discountAmount: 50,
        applicableCommodityIds: {},
      );

      final result = CheckoutPriceCalculator.applyVoucherDiscounts(
        items: items,
        selectedTotal: 100.0,
        appliedVoucher: voucher,
      );

      expect(result.first.pricePerKg, 50.0);
    });

    test('applyVoucherDiscounts amount voucher with commodity filtering', () {
      final items = [
        _makeItem(id: '10', name: 'Eligible', price: 100.0, quantity: 1),
        _makeItem(id: '20', name: 'Ineligible', price: 50.0, quantity: 1),
      ];
      const voucher = AppliedVoucher(
        saleId: 's1',
        name: 'Amount Voucher',
        code: 'OFF25',
        discountType: 'amount',
        discountValue: 25,
        targetUserGroup: 'all',
        discountAmount: 25,
        applicableCommodityIds: {10},
      );

      final result = CheckoutPriceCalculator.applyVoucherDiscounts(
        items: items,
        selectedTotal: 150.0,
        appliedVoucher: voucher,
      );

      // Total = 150, portion = 25 / 150 = 0.166666...
      // Item 10: 100 * (1 - 0.166666...) = 83.33
      expect(result[0].pricePerKg, 83.33);
      // Item 20 unaffected
      expect(result[1].pricePerKg, 50.0);
    });
  });

  group('CheckoutOrderSubmission', () {
    test('isGcashMatched validates farm matching for GCash payment', () {
      final items = [
        _makeItem(id: '1', name: 'Item', price: 10.0, farmId: 5),
      ];

      expect(
        CheckoutOrderSubmission.isGcashMatched(
          payment: const OrderPayment.cashOnDelivery(),
          items: items,
          gcashFarmId: null,
        ),
        isTrue,
      );

      expect(
        CheckoutOrderSubmission.isGcashMatched(
          payment: OrderPayment.gcash('REF123'),
          items: items,
          gcashFarmId: 5,
        ),
        isTrue,
      );

      expect(
        CheckoutOrderSubmission.isGcashMatched(
          payment: OrderPayment.gcash('REF123'),
          items: items,
          gcashFarmId: 99,
        ),
        isFalse,
      );
    });
  });

  group('CheckoutInventoryReconciler', () {
    test('isInventoryFailure detects out-of-stock messages', () {
      expect(
        CheckoutInventoryReconciler.isInventoryFailure('Insufficient stock'),
        isTrue,
      );
      expect(
        CheckoutInventoryReconciler.isInventoryFailure('Only 2 kg remains'),
        isTrue,
      );
      expect(
        CheckoutInventoryReconciler.isInventoryFailure(
          'Item is no longer available',
        ),
        isTrue,
      );
      expect(
        CheckoutInventoryReconciler.isInventoryFailure(
          'Farmer not accepting orders',
        ),
        isTrue,
      );
      expect(
        CheckoutInventoryReconciler.isInventoryFailure('Network error'),
        isFalse,
      );
    });
  });

  group('CheckoutFarmerMessenger', () {
    test('hasSameSeller checks farmId and fallback to name/location', () {
      final item1 = _makeItem(id: '1', name: 'A', price: 10, farmId: 1);
      final item2 = _makeItem(id: '2', name: 'B', price: 20, farmId: 1);
      final item3 = _makeItem(id: '3', name: 'C', price: 30, farmId: 2);

      expect(CheckoutFarmerMessenger.hasSameSeller(item1, item2), isTrue);
      expect(CheckoutFarmerMessenger.hasSameSeller(item1, item3), isFalse);

      final itemNoFarmId1 = _makeItem(
        id: '4',
        name: 'D',
        price: 10,
        farmId: null,
        sellerName: 'Juan',
        sellerLocation: 'Davao',
      );
      final itemNoFarmId2 = _makeItem(
        id: '5',
        name: 'E',
        price: 10,
        farmId: null,
        sellerName: 'Juan',
        sellerLocation: 'Davao',
      );
      expect(
        CheckoutFarmerMessenger.hasSameSeller(itemNoFarmId1, itemNoFarmId2),
        isTrue,
      );
    });
  });
}
