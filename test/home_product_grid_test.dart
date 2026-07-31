import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_grid_skeleton.dart';
import 'package:agresell_app/core/widgets/responsiveAssetImage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_product_fixture.dart';

void main() {
  testWidgets('home product grid keeps the original image height', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    Future<void> pumpGrid(Size size) async {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              slivers: [HomeProductGrid(products: testHomeProducts)],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpGrid(const Size(320, 568));
    expect(tester.getSize(find.byType(Hero).first).height, 154);
    final productImage = tester.widget<ResponsiveAssetImage>(
      find.descendant(
        of: find.byType(Hero).first,
        matching: find.byType(ResponsiveAssetImage),
      ),
    );
    expect(productImage.fit, BoxFit.cover);
    expect(productImage.decodeWidth, 1200);
    expect(productImage.gaplessPlayback, isTrue);
    expect(
      tester.widget<Hero>(find.byType(Hero).first).transitionOnUserGestures,
      isTrue,
    );
    expect(tester.takeException(), isNull);

    await pumpGrid(const Size(430, 932));
    expect(tester.getSize(find.byType(Hero).first).height, 154);
    expect(tester.takeException(), isNull);
  });

  testWidgets('product skeleton matches the grid and card dimensions', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [HomeProductGridSkeleton(itemCount: 4)],
          ),
        ),
      ),
    );
    await tester.pump();

    final cards = find.byKey(const ValueKey('home-product-skeleton-card'));
    expect(cards, findsNWidgets(4));
    expect(tester.getSize(cards.first).height, 270);
    expect(find.bySemanticsLabel('Loading product'), findsNWidgets(4));
    expect(tester.takeException(), isNull);
  });
}
