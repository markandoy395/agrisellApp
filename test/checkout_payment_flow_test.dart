import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/buyer/cart/data/checkout_payment_repository.dart';
import 'package:agresell_app/features/shared/payments/domain/farmer_gcash_details.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';

void main() {
  final basket = BasketController.instance;
  final orders = OrderController.instance;

  setUp(() {
    basket.clear();
    orders.clear();
  });

  tearDown(() {
    basket.clear();
    orders.clear();
  });

  testWidgets('buyer selects GCash and submits a reference for verification', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'confirmed_location_buyer_v1': jsonEncode({
        'latitude': 8.1575,
        'longitude': 125.1277,
        'accuracyMeters': 6.0,
        'capturedAt': '2026-07-29T08:00:00.000Z',
        'address': 'Test delivery address',
        'notes': null,
      }),
    });
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    basket.addProduct(_product);

    await tester.pumpWidget(
      const MaterialApp(
        home: CheckoutScreen(
          initialDeliveryAddress: 'Test delivery address',
          paymentRepository: _FakeCheckoutPaymentRepository(),
          gcashReceiptImagePicker: _pickReceiptImage,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('GCash'));
    await tester.tap(find.text('GCash'));
    await tester.pumpAndSettle();
    expect(find.text('Pay with GCash'), findsOneWidget);
    expect(find.text('09171234567'), findsOneWidget);
    expect(find.textContaining('does not mark the order paid'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('gcash-reference-field')),
      '1234567890123',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('gcash-receipt-upload-button')));
    await tester.pumpAndSettle();
    expect(find.text('gcash-receipt.png'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('use-gcash-button')));
    await tester.pumpAndSettle();
    expect(find.text('Reference 1234567890123'), findsOneWidget);

    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();
    expect(orders.orders, hasLength(1));
    expect(orders.orders.single.payment.method, OrderPaymentMethod.gcash);
    expect(
      orders.orders.single.payment.status,
      OrderPaymentStatus.submittedForVerification,
    );
    expect(orders.orders.single.payment.transactionReference, '1234567890123');
    expect(orders.orders.single.payment.hasReceiptImage, isTrue);
    expect(orders.orders.single.payment.receiptImageName, 'gcash-receipt.png');
    expect(orders.orders.single.deliveryLatitude, 8.1575);
    expect(orders.orders.single.deliveryLongitude, 125.1277);
    expect(tester.takeException(), isNull);
  });
}

Future<GcashReceiptImage> _pickReceiptImage() async => GcashReceiptImage(
  fileName: 'gcash-receipt.png',
  bytes: base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADElEQVR42mP8z8AARQAFAgHh'
    'AJn6AAAAAElFTkSuQmCC',
  ),
  proofReference: 'local-secure://gcash-receipts/test',
);

const _product = HomeProduct(
  id: '1',
  name: 'Fresh Tomato',
  price: '₱50',
  unit: 'per kg',
  image: 'assets/images/vege.jpeg',
  harvestDate: 'July 29, 2026',
  availableWeight: '20 kg',
  sellerName: 'Maria Farmer',
  sellerLocation: 'Bukidnon',
  farmId: 7,
);

class _FakeCheckoutPaymentRepository implements CheckoutPaymentRepository {
  const _FakeCheckoutPaymentRepository();

  @override
  Future<List<FarmerGcashDetails>> loadGcashDetails(
    Iterable<int> farmIds,
  ) async => const [
    FarmerGcashDetails(
      farmId: 7,
      farmerName: 'Maria Farmer',
      accountName: 'Maria Dela Cruz',
      accountNumber: '09171234567',
    ),
  ];
}
