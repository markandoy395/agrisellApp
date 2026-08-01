import 'package:agresell_app/core/constants/agrisell_assets.dart';
import 'package:agresell_app/core/constants/agrisell_routes.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/orders/domain/basket_cart_item.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_item.dart';
import 'package:agresell_app/features/buyer/home/domain/farmer_profile.dart';
import 'package:agresell_app/features/shared/products/domain/home_product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping a basket seller opens the matching farmer shop', (
    tester,
  ) async {
    final product = HomeProduct(
      id: 'test-product',
      name: 'Fresh tomatoes',
      price: '₱50',
      unit: 'per kg',
      image: AgrisellAssets.homeBannerVegetables,
      harvestDate: 'May 10, 2025',
      availableWeight: '90 kg',
      sellerName: 'Jake Andoy',
      sellerLocation: 'Bukidnon',
      farmId: 42,
    );
    FarmerProfile? openedFarmer;

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        onGenerateRoute: (settings) {
          if (settings.name == AgrisellRoutes.farmerShop) {
            openedFarmer = settings.arguments! as FarmerProfile;
            return MaterialPageRoute<void>(
              builder: (_) => const Scaffold(body: Text('Farmer Shop')),
            );
          }
          return null;
        },
        home: Scaffold(
          body: BasketItem(
            item: BasketCartItem.fromProduct(product),
            onSelectedChanged: (_) {},
            onIncrement: () {},
            onDecrement: () {},
            onRemove: () {},
          ),
        ),
      ),
    );

    await tester.tap(find.text('Jake Andoy'));
    await tester.pumpAndSettle();

    expect(find.text('Farmer Shop'), findsOneWidget);
    expect(openedFarmer?.farmId, 42);
    expect(openedFarmer?.name, 'Jake Andoy');
  });
}
