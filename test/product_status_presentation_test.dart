import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/buyer/home/presentation/widgets/product_detail/product_detail_info_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_product_card.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/domain/product_production_stage.dart';
import 'package:agresell_app/features/shared/products/domain/product_sale_status.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';

void main() {
  final product = HomeProduct(
    id: 'status-product',
    name: 'Pre-harvest tomatoes',
    price: '\u20B150',
    unit: 'per kg',
    image: 'assets/images/vege.jpeg',
    harvestDate: 'August 5, 2026',
    availableWeight: '20 kg',
    sellerName: 'Test Farmer',
    sellerLocation: 'Bukidnon',
    productionStage: ProductProductionStage.harvestingSoon,
    saleStatus: ProductSaleStatus.preOrder,
    estimatedHarvestDate: DateTime(2026, 8, 5),
  );

  testWidgets('buyer product card uses accessible status icons', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            child: HomeProductCard(product: product, onTap: () {}),
          ),
        ),
      ),
    );

    expect(
      find.bySemanticsLabel('Production: Harvesting soon'),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('Selling: Accepting pre-orders'),
      findsOneWidget,
    );
    expect(find.text('Production: Harvesting soon'), findsNothing);
    expect(find.text('Available: 20 kg'), findsOneWidget);
  });

  testWidgets('farmer shop product card shows available quantity', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 320,
            child: FarmerProductCard(product: product, onTap: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Available: 20 kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('buyer product details show full status text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ProductInfoCard(
              product: product,
              quantity: 1,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Production: Harvesting soon'), findsOneWidget);
    expect(find.text('Selling: Accepting pre-orders'), findsOneWidget);
    expect(find.text('Available: 20 kg'), findsOneWidget);
  });
}
