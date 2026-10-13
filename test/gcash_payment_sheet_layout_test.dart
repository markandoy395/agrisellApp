import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/cart/data/checkout_payment_repository.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/payments/domain/farmer_gcash_details.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final fails in [false, true]) {
    testWidgets(
      'GCash unavailable state distinguishes load failure $fails and offers COD',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.reset);
        final repository = _Repository(fails: fails);
        GcashPaymentSelection? selection;
        await _open(tester, repository, (value) => selection = value);
        await tester.pumpAndSettle();
        expect(
          find.textContaining(
            fails
                ? 'Unable to load GCash details'
                : 'This farmer has not shared',
          ),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('use-gcash-button')), findsNothing);
        await tester.ensureVisible(find.text('Retry'));
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(repository.calls, 2);
        await tester.ensureVisible(find.text('Use Cash on Delivery'));
        await tester.tap(find.text('Use Cash on Delivery'));
        await tester.pumpAndSettle();
        expect(selection?.payment.method, OrderPaymentMethod.cashOnDelivery);
        expect(selection?.farmId, isNull);
        expect(find.text('Pay with GCash'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'GCash form and submit button remain reachable above keyboard with large text',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);
      await _open(tester, _Repository(complete: true), (_) {});
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('gcash-reference-field'));
      await tester.ensureVisible(field);
      await tester.enterText(field, '1234567890123');
      await tester.pumpAndSettle();
      final submit = find.byKey(const ValueKey('use-gcash-button'));
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();
      expect(tester.getBottomRight(submit).dy, lessThanOrEqualTo(380));
      expect(tester.getSize(submit).height, greaterThanOrEqualTo(48));
      expect(tester.widget<FilledButton>(submit).onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _open(
  WidgetTester tester,
  CheckoutPaymentRepository repository,
  ValueChanged<GcashPaymentSelection?> onSelected,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AgrisellTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => onSelected(
              await showGcashPaymentSheet(
                context,
                items: [BasketCartItem.fromProduct(_product)],
                total: 10,
                repository: repository,
              ),
            ),
            child: const Text('Open GCash'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open GCash'));
}

const _product = HomeProduct(
  id: '1',
  name: 'Lettuce',
  price: '10',
  unit: 'per kg',
  image: 'assets/images/vege.jpeg',
  harvestDate: 'August 9, 2026',
  availableWeight: '20 kg',
  sellerName: 'Test Farmer',
  sellerLocation: 'Lianga',
  farmId: 7,
);

class _Repository implements CheckoutPaymentRepository {
  _Repository({this.fails = false, this.complete = false});
  final bool fails;
  final bool complete;
  var calls = 0;
  @override
  Future<List<FarmerGcashDetails>> loadGcashDetails(
    Iterable<int> farmIds,
  ) async {
    calls++;
    if (fails) throw const CheckoutPaymentException('connection_error');
    return complete
        ? const [
            FarmerGcashDetails(
              farmId: 7,
              farmerName: 'Test Farmer',
              accountName: 'Test Farmer',
              accountNumber: '09171234567',
            ),
          ]
        : [];
  }
}
