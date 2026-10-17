import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/buyer/cart/presentation/controllers/basket_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/controllers/home_product_browse_controller.dart';
import 'package:agresell_app/features/buyer/home/presentation/screens/all_products_screen.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/catalog/buyer_catalog_card.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/catalog/buyer_catalog_grid.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_dashboard_content.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:agresell_app/features/shared/products/presentation/controllers/home_product_catalog_controller.dart';
import 'support/authenticated_test_session.dart';

void main() {
  configureAuthenticatedTests();
  setUpAll(() async {
    final loader = FontLoader('Poppins');
    loader.addFont(rootBundle.load('assets/fonts/Poppins/Poppins-Regular.ttf'));
    await loader.load();
    final icons = FontLoader('MaterialIcons');
    icons.addFont(
      File(
        'assets/fonts/MaterialIcons-Regular.otf',
      ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
    );
    await icons.load();
  });
  testWidgets(
    'all products filters, sorts active prices, saves and adds to basket',
    (tester) async {
      _size(tester, 390);
      final catalog = _Catalog();
      final browse = HomeProductBrowseController();
      addTearDown(catalog.dispose);
      addTearDown(browse.dispose);
      String? opened;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: RepaintBoundary(
            key: boundary,
            child: AllProductsScreen(
              catalogController: catalog,
              browseController: browse,
              onProductTap: (product) => opened = product.id,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid));
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        2,
      );
      expect(find.text('4 products'), findsOneWidget);
      expect(find.text('Unavailable'), findsNothing);
      await _capture(tester, boundary, 'all_products');
      await tester.tap(find.text('Fruits'));
      await tester.pumpAndSettle();
      expect(find.text('1 product'), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Tomatoes'), findsNothing);
      await tester.tap(find.text('All', skipOffstage: false));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Sort products'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(
          CheckedPopupMenuItem<HomeProductSort>,
          'Price: low to high',
        ),
      );
      await tester.pumpAndSettle();
      final cards = tester
          .widgetList<BuyerCatalogCard>(find.byType(BuyerCatalogCard))
          .toList();
      expect(cards.map((card) => card.product.id), [
        'tomatoes',
        'lettuce',
        'mango',
        'ginger',
      ]);
      await tester.tap(find.byTooltip('Save Tomatoes'));
      await tester.pumpAndSettle();
      expect(browse.isSaved('tomatoes'), isTrue);
      final before = BasketController.instance.totalQuantity;
      await tester.tap(find.byTooltip('Add Tomatoes to basket'));
      await tester.pumpAndSettle();
      expect(BasketController.instance.totalQuantity, before + 1);
      await tester.tap(find.text('Tomatoes'));
      expect(opened, 'tomatoes');
      await tester.tap(find.byTooltip('Search products'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Mango');
      await tester.pumpAndSettle();
      expect(find.byType(BuyerCatalogCard), findsOneWidget);
      expect(
        tester
            .widget<BuyerCatalogCard>(find.byType(BuyerCatalogCard))
            .product
            .name,
        'Mango',
      );
      expect(tester.takeException(), isNull);
      AuthSessionService.instance.clearMemoryForTesting();
      await tester.pumpAndSettle();
      expect(find.byType(BuyerCatalogCard), findsNothing);
    },
  );

  testWidgets('home View All opens full catalog and returns to existing tabs', (
    tester,
  ) async {
    _size(tester, 390);
    final catalog = _Catalog();
    addTearDown(catalog.dispose);
    int? selectedTab;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: HomeDashboardContent(
            catalogController: catalog,
            onProductTap: (_, _) {},
            onSelectTab: (index) => selectedTab = index,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sale products'), findsNothing);
    expect(find.text('Fresh picks'), findsOneWidget);
    final viewAll = find.byKey(const ValueKey('home-products-view-all'));
    await tester.ensureVisible(viewAll);
    await tester.tap(viewAll);
    await tester.pumpAndSettle();
    expect(find.byType(AllProductsScreen), findsOneWidget);
    expect(find.text('4 products'), findsOneWidget);
    await tester.tap(find.text('Messages'));
    await tester.pumpAndSettle();
    expect(selectedTab, 1);
    expect(find.byType(AllProductsScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 700.0]) {
    testWidgets('combined grid fits at $width and enlarged device text', (
      tester,
    ) async {
      _size(tester, width);
      final boundary = GlobalKey();
      final browse = HomeProductBrowseController();
      addTearDown(browse.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: RepaintBoundary(
            key: boundary,
            child: Scaffold(
              body: CustomScrollView(
                slivers: [
                  BuyerCatalogGrid(
                    sale: true,
                    products: List.generate(
                      12,
                      (index) => _product(
                        '$index',
                        'Tomatoes',
                        'Vegetables',
                        '40',
                        '34',
                      ),
                    ),
                    browseController: browse,
                    onProductTap: (_) {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<SliverGrid>(find.byType(SliverGrid))
            .delegate
            .estimatedChildCount,
        12,
      );
      if (width == 390) await _capture(tester, boundary, 'home_sales');
      tester.platformDispatcher.textScaleFactorTestValue = 1.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

void _size(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(() async {
    for (final image in tester.widgetList<Image>(find.byType(Image))) {
      await precacheImage(image.image, key.currentContext!);
    }
  });
  await tester.pumpAndSettle();
  for (final asset in tester.widgetList<ResponsiveAssetImage>(
    find.byType(ResponsiveAssetImage),
  )) {
    if (asset.asset != null) {
      expect(File(asset.asset!).lengthSync(), greaterThan(0));
      expect(tester.getSize(find.byWidget(asset)).height, greaterThan(0));
    }
  }
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/buyer_catalog_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

class _Catalog extends HomeProductCatalogController {
  @override
  HomeProductCatalogStatus get status => HomeProductCatalogStatus.ready;
  @override
  bool get hasMore => false;
  @override
  List<HomeProduct> get products => [
    _product('lettuce', 'Lettuce', 'Vegetables', '10'),
    _product('tomatoes', 'Tomatoes', 'Vegetables', '40', '9'),
    _product('mango', 'Mango', 'Fruits', '20'),
    _product('ginger', 'Ginger', 'Spices', '30'),
    _product('unavailable', 'Unavailable', 'Vegetables', '0', null, false),
  ];
}

HomeProduct _product(
  String id,
  String name,
  String category,
  String price, [
  String? salePrice,
  bool available = true,
]) => HomeProduct(
  id: id,
  name: name,
  price: '₱$price',
  salePrice: salePrice == null ? null : '₱$salePrice',
  category: category,
  unit: 'per kg',
  image: 'assets/images/home/vegetable.png',
  harvestDate: 'January 1, 2030',
  availableWeight: '10 kg',
  sellerName: 'Test farm',
  sellerLocation: 'Test city',
  isAvailable: available,
);
