import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final basketController = BasketController.instance;

  setUp(basketController.clear);
  tearDown(basketController.clear);

  testWidgets('unavailable product disables quantity and purchase actions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final unavailableProduct = testHomeProducts.firstWhere(
      (product) => !product.isAvailable,
    );

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: ProductDetailScreen(product: unavailableProduct),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Currently Unavailable'), findsOneWidget);
    expect(
      find.text('This product is not accepting orders right now.'),
      findsOneWidget,
    );
    expect(find.text('Buy Now'), findsNothing);
    expect(find.text('Add to Basket'), findsNothing);
    final increaseButton = find.byWidgetPredicate(
      (widget) => widget is IconButton && widget.tooltip == 'Increase quantity',
    );
    expect(tester.widget<IconButton>(increaseButton).onPressed, isNull);
    expect(basketController.items, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
