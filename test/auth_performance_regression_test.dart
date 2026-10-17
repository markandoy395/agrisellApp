import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/home_product_fixture.dart';

void main() {
  testWidgets('keyboard insets do not resize or replace the auth background', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const AuthScaffold(
          title: 'Sign Up',
          child: Column(
            children: [
              AuthTextField(hintText: 'Email'),
              Spacer(),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final backgroundFinder = find.byType(AuthBackground);
    final imageFinder = find.descendant(
      of: backgroundFinder,
      matching: find.byType(Image),
    );
    final providerBefore = tester.widget<Image>(imageFinder).image;
    final sizeBefore = tester.getSize(backgroundFinder);
    final headerBefore = tester.widget<LogoHeader>(find.byType(LogoHeader));

    await tester.tap(find.byType(TextField));
    tester.view.viewInsets = const FakeViewPadding(bottom: 330);
    await tester.pumpAndSettle();

    final providerAfter = tester.widget<Image>(imageFinder).image;
    expect(tester.getSize(backgroundFinder), sizeBefore);
    expect(providerAfter, providerBefore);
    expect(
      tester.widget<LogoHeader>(find.byType(LogoHeader)),
      same(headerBefore),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('marketplace card decodes its image at rendered bounds', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1290, 2796);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 252,
              child: HomeProductCard(
                product: testHomeProducts.first,
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final image = tester.widget<Image>(
      find.descendant(
        of: find.byType(HomeProductCard),
        matching: find.byType(Image),
      ),
    );
    expect(image.image, isA<ResizeImage>());
    final provider = image.image as ResizeImage;
    expect(provider.width, 600);
    expect(provider.height, (HomeProductCard.imageHeight * 3).ceil());
    expect(tester.takeException(), isNull);
  });
}
