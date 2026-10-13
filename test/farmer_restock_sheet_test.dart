import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_restock.dart';
import 'package:agresell_app/features/farmer/products/presentation/widgets/farmer_restock_dialog.dart';
import 'package:agresell_app/features/shared/products/domain/product_inventory_lot.dart';

void main() {
  const product = FarmerDashboardProduct(
    name: 'Lettuce',
    price: '50',
    unit: 'kg',
    harvestDate: '',
    category: 'Vegetables',
    imageAsset: AgrisellAssets.categoryVegetable,
    availableWeight: '7 kg',
    inventoryDateType: ProductInventoryDateType.freshProduce,
  );

  for (final width in [320.0, 430.0]) {
    testWidgets('fresh restock sheet works at $width with keyboard insets', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      FarmerRestockRequest? request;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  request = await showFarmerRestockDialog(
                    context,
                    product: product,
                  );
                },
                child: const Text('Restock'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Restock'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('7 kg'), findsNWidgets(2));
      await tester.tap(find.byKey(const Key('confirm-restock-button')));
      await tester.pumpAndSettle();
      expect(request, isNull);
      await tester.enterText(
        find.byKey(const Key('restock-quantity-field')),
        '2.5',
      );
      await tester.pump();
      expect(find.text('9.5 kg'), findsOneWidget);

      tester.view.viewInsets = const FakeViewPadding(bottom: 220);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.byKey(const Key('restock-storage-field')),
      );
      await tester.enterText(
        find.byKey(const Key('restock-storage-field')),
        'Keep refrigerated',
      );
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('restock-marketable-until-field')),
      );
      await tester.tap(find.byKey(const Key('restock-marketable-until-field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm-restock-button')));
      await tester.pumpAndSettle();
      expect(request?.quantity, 2.5);
      expect(request?.inventoryLot.storageInstructions, 'Keep refrigerated');
      expect(request?.inventoryLot.sellUntil, isNotNull);
      expect(tester.takeException(), isNull);
    });
  }
}
