import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';

const _product = FarmerDashboardProduct(
  commodityId: 201,
  farmId: 10,
  name: 'Lettuce',
  price: '\u20b110',
  unit: 'per kg',
  harvestDate: '2026-09-20',
  category: 'Vegetables',
  imageAsset: 'assets/images/vege.jpeg',
  availableWeight: '4 kg',
);

void main() {
  for (final navigationInset in [0.0, 24.0, 48.0]) {
    for (final action in ['Save', 'Cancel']) {
      testWidgets('$action respects inset $navigationInset and keyboard', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 700);
        tester.view.viewPadding = FakeViewPadding(bottom: navigationInset);
        tester.view.padding = FakeViewPadding(bottom: navigationInset);
        addTearDown(tester.view.reset);
        FarmerDashboardProduct? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await Navigator.of(context)
                        .push<FarmerDashboardProduct>(
                          MaterialPageRoute(
                            builder: (_) => const FarmerProductEditScreen(
                              product: _product,
                            ),
                          ),
                        );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final save = find.widgetWithText(FilledButton, 'Save');
        final cancel = find.widgetWithText(OutlinedButton, 'Cancel');
        for (final button in [save, cancel]) {
          expect(button.hitTestable(), findsOneWidget);
          expect(
            tester.getRect(button).bottom,
            lessThanOrEqualTo(676 - navigationInset),
          );
        }
        await tester.enterText(find.byType(TextField).first, 'Fresh Lettuce');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        tester.view.padding = FakeViewPadding.zero;
        await tester.pumpAndSettle();
        for (final button in [save, cancel]) {
          expect(button.hitTestable(), findsOneWidget);
          expect(tester.getRect(button).bottom, lessThanOrEqualTo(376));
        }
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -900),
        );
        await tester.pumpAndSettle();
        expect(save.hitTestable(), findsOneWidget);
        expect(cancel.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        tester.view.viewInsets = FakeViewPadding.zero;
        tester.view.padding = FakeViewPadding(bottom: navigationInset);
        await tester.pumpAndSettle();
        expect(
          tester.getRect(save).bottom,
          lessThanOrEqualTo(676 - navigationInset),
        );
        await tester.tap(action == 'Save' ? save : cancel);
        await tester.pumpAndSettle();
        expect(find.text('Open'), findsOneWidget);
        expect(result?.name, action == 'Save' ? 'Fresh Lettuce' : null);
        expect(result?.commodityId, action == 'Save' ? 201 : null);
        expect(tester.takeException(), isNull);
      });
    }
  }
}
