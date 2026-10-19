import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/farmer/dashboard/presentation/screens/farmer_dashboard_screen.dart';
import 'package:agresell_app/features/farmer/products/data/farmer_commodity_repository.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_reserve_skeleton.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/farmer_shop/farmer_product_grid.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';

void main() {
  testWidgets('farmer products retain skeletons until the load completes', (
    tester,
  ) async {
    final repository = _PendingProducts();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerDashboardScreen(commodityRepository: repository),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(HomeProductGridSkeleton), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    repository.result.complete([]);
    await tester.pumpAndSettle();
    expect(find.byType(HomeProductGridSkeleton), findsNothing);
    expect(
      find.text('Products from the backend will appear here.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 430.0]) {
    testWidgets('skeletons fit $width and respect reduced motion', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      Widget app(Widget body) => MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: Scaffold(body: body),
      );
      await tester.pumpWidget(app(const FarmerReserveSkeleton()));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Loading reservations'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        app(
          CustomScrollView(
            slivers: [
              FarmerProductGrid(
                products: const [],
                isLoading: true,
                loadFailed: false,
                onRetry: () {},
                onProductTap: (_) {},
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeProductGridSkeleton), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}

class _PendingProducts extends FarmerCommodityRepository {
  final result = Completer<List<FarmerDashboardProduct>>();

  @override
  bool get isAvailable => true;

  @override
  Future<List<FarmerDashboardProduct>> loadProducts() => result.future;
}
