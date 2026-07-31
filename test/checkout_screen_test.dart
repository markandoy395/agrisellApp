import 'package:agresell_app/core/constants/agrisellRoutes.dart';
import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'support/home_product_fixture.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/basket_screen.dart';
import 'package:agresell_app/features/buyer/cart/presentation/screens/checkout_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/product_detail_screen.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final controller = BasketController.instance;
  final orderController = OrderController.instance;
  setUp(() {
    controller.clear();
    orderController.clear();
  });
  tearDown(() {
    controller.clear();
    orderController.clear();
  });
  testWidgets(
    'checkout button opens checkout screen for selected basket items',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      controller.addProduct(testHomeProducts[0], quantity: 2);
      controller.addProduct(testHomeProducts[1], quantity: 3);
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AgrisellTheme.light,
          routes: {AgrisellRoutes.checkout: (_) => const CheckoutScreen()},
          home: const BasketScreen(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Basket'), findsOneWidget);
      expect(find.text('Checkout'), findsOneWidget);
      await tester.tap(find.text('Checkout'));
      await tester.pumpAndSettle();
      expect(find.text('Checkout'), findsOneWidget);
      expect(find.text('Pumpkin / Kalabasa'), findsOneWidget);
      expect(find.text('Seasonal Harvest'), findsOneWidget);
      expect(find.text('Payment Methods'), findsOneWidget);
      expect(find.text('Set desired delivery date'), findsNothing);
      expect(find.text('Place Order'), findsOneWidget);
      expect(find.textContaining('\u20B1 135'), findsOneWidget);
    },
  );
  testWidgets('basket product removal can be undone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final product = testHomeProducts.first;
    controller.addProduct(product, quantity: 2);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: const BasketScreen(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('remove-${product.id}')));
    await tester.pumpAndSettle();
    expect(controller.items, isEmpty);
    expect(find.text('Undo'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(controller.items, hasLength(1));
    expect(controller.items.single.quantity, 2);
    expect(find.text(product.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('buy now opens checkout with the current product selected', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final product = testHomeProducts.first;
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        routes: {AgrisellRoutes.checkout: (_) => const CheckoutScreen()},
        home: ProductDetailScreen(product: product),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buy Now'));
    await tester.pumpAndSettle();
    expect(find.text('Checkout'), findsOneWidget);
    expect(find.text(product.name), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);
    expect(controller.selectedQuantity, 1);
    expect(controller.selectedTotal, 15);
  });
  testWidgets('product details show content within the first mobile viewport', (
    tester,
  ) async {
    const screenSize = Size(430, 932);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = screenSize;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: ProductDetailScreen(product: testHomeProducts.first),
      ),
    );
    await tester.pumpAndSettle();
    final detailsPanel = find.byKey(const ValueKey('product-details-panel'));
    expect(detailsPanel, findsOneWidget);
    expect(tester.getTopLeft(detailsPanel).dy, lessThan(screenSize.height / 2));
    expect(find.text('About Product'), findsOneWidget);
    expect(find.text('Recommended for you'), findsNothing);
    expect(find.text('Add to Basket'), findsOneWidget);
    final productImage = tester.widget<ResponsiveAssetImage>(
      find
          .byWidgetPredicate(
            (widget) =>
                widget is ResponsiveAssetImage &&
                widget.asset == testHomeProducts.first.image,
          )
          .first,
    );
    expect(productImage.fit, BoxFit.cover);
    expect(productImage.decodeWidth, 1200);
    expect(productImage.gaplessPlayback, isTrue);
    expect(find.byType(Hero), findsOneWidget);
    final productHero = tester.widget<Hero>(find.byType(Hero));
    expect(productHero.tag, 'home-product-${testHomeProducts.first.id}');
    expect(productHero.transitionOnUserGestures, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('product details remain usable on compact mobile screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: ProductDetailScreen(product: testHomeProducts.first),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Add to Basket'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Recommended for you'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
