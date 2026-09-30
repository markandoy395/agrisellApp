import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/farmer_product_edit_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';

class FakeFarmerCommodityRepository extends FarmerCommodityRepository {
  const FakeFarmerCommodityRepository(this.products);
  final List<FarmerDashboardProduct> products;

  @override
  bool get isAvailable => true;

  @override
  Future<List<FarmerDashboardProduct>> loadProducts() async => products;
}

void main() {
  final productWithSale = FarmerDashboardProduct(
    commodityId: 101,
    farmId: 1,
    name: 'Organic Tomatoes',
    price: '\u20b180.00',
    unit: 'per kg',
    harvestDate: '2026-09-20',
    category: 'Vegetables',
    availableWeight: '50 kg',
    imageAsset: 'assets/images/vege.jpeg',
    activeSaleName: 'Weekend Flash Sale',
    activeSaleDiscount: '15% OFF',
    activeSaleEndsAt: DateTime(2026, 9, 30),
  );

  final productWithoutSale = FarmerDashboardProduct(
    commodityId: 102,
    farmId: 1,
    name: 'Fresh Carrots',
    price: '\u20b160.00',
    unit: 'per kg',
    harvestDate: '2026-09-20',
    category: 'Vegetables',
    availableWeight: '30 kg',
    imageAsset: 'assets/images/vege.jpeg',
  );

  testWidgets('farmer dashboard displays active admin sale badge on product card', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repo = FakeFarmerCommodityRepository([productWithSale, productWithoutSale]);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: FarmerDashboardScreen(commodityRepository: repo),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check product on sale shows badge and sale details
    expect(find.text('Organic Tomatoes'), findsOneWidget);
    expect(find.text('15% OFF'), findsOneWidget);
    expect(find.text('In Sale: Weekend Flash Sale'), findsOneWidget);

    // Check product without sale does not show sale indicator
    expect(find.text('Fresh Carrots'), findsOneWidget);
    expect(find.text('In Sale: Fresh Carrots'), findsNothing);
  });

  testWidgets('farmer product edit screen displays active sale alert banner when in sale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: FarmerProductEditScreen(product: productWithSale),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Featured in Active Admin Sale'), findsOneWidget);
    expect(find.textContaining('Weekend Flash Sale (15% OFF)'), findsOneWidget);
  });

  testWidgets('farmer product edit screen does not display active sale alert banner when not in sale', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AgrisellTheme.light,
        home: FarmerProductEditScreen(product: productWithoutSale),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Featured in Active Admin Sale'), findsNothing);
  });
}
