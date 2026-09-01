import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows sale pricing without covering the product image', (
    tester,
  ) async {
    const product = HomeProduct(
      id: 'sale-mango',
      name: 'Mango',
      price: '\u20B1100',
      salePrice: '\u20B180',
      unit: 'kg',
      image: 'assets/images/vege.jpeg',
      harvestDate: 'August 27, 2026',
      availableWeight: '12 kg',
      sellerName: 'Test Farm',
      sellerLocation: 'Lianga',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: HomeProductCard.heightForWidth(430),
              child: HomeProductCard(product: product, onTap: () {}),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SALE'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp(r'On sale for ₱80 kg')),
      findsOneWidget,
    );
    expect(find.text('\u20B1100'), findsOneWidget);
    expect(find.textContaining('\u20B180'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
