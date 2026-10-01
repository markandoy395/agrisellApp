import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/data/home_banners.dart';
import 'package:agresell_app/features/buyer/home/domain/home_banner.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_banner_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('treats the expiry timestamp as an exclusive deadline', () {
    final banner = HomeBanner(
      image: 'image',
      prefix: 'Save ',
      highlight: '50%',
      subtitle: 'Discount',
      title: 'Product',
      expiryLabel: 'Aug 31, 2026',
      expiresAt: DateTime(2026, 9, 1),
    );

    expect(banner.isExpiredAt(DateTime(2026, 8, 31, 23, 59)), isFalse);
    expect(banner.isExpiredAt(DateTime(2026, 9, 1)), isTrue);
  });

  testWidgets('shows the buyer home vegetable promotion', (tester) async {
    final controller = PageController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 430,
              child: HomeBannerCarousel(
                controller: controller,
                height: 206,
                banners: homeBanners,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('Save Up to', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('Discount of'), findsOneWidget);
    expect(find.text('VEGETABLE PRODUCT  •  ON SALE'), findsOneWidget);
    expect(find.text('VEGETABLE\nPRODUCT'), findsOneWidget);
    expect(find.text('VALID UNTIL'), findsOneWidget);
    expect(find.text('Aug 31, 2026'), findsOneWidget);
    expect(find.bySemanticsLabel('Valid until Aug 31, 2026'), findsOneWidget);
    expect(
      find.bySemanticsLabel('VEGETABLE\nPRODUCT promotion'),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Banner 1 of 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('loops banners and resumes automatic scrolling after a drag', (
    tester,
  ) async {
    final controller = PageController(initialPage: 1, viewportFraction: 0.78);
    addTearDown(controller.dispose);
    final banners = <HomeBanner>[
      homeBanners.first,
      HomeBanner(
        image: homeBanners.first.image,
        prefix: 'Fresh ',
        highlight: '20%',
        subtitle: 'Savings on',
        title: 'FRUIT\nPRODUCT',
        expiryLabel: 'Sep 30, 2026',
        expiresAt: DateTime(2030, 10, 1),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 430,
              child: HomeBannerCarousel(
                controller: controller,
                height: 206,
                banners: banners,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.widget<PageView>(find.byType(PageView)).reverse, isTrue);
    expect(find.bySemanticsLabel('Banner 1 of 2'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('home-banner-indicator-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('home-banner-indicator-1')),
      findsOneWidget,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(PageView)),
    );
    await tester.pump(const Duration(seconds: 6));
    expect(find.bySemanticsLabel('Banner 1 of 2'), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.bySemanticsLabel('Banner 2 of 2'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens one promoted campaign from its banner', (tester) async {
    final controller = PageController(viewportFraction: 0.78);
    addTearDown(controller.dispose);
    var openedSaleId = 0;
    final campaign = HomeBanner(
      id: 'campaign:42',
      source: HomeBannerSource.campaign,
      campaignSaleId: 42,
      image: homeBanners.first.image,
      prefix: 'Save ',
      highlight: '20%',
      subtitle: 'Farm-wide sale',
      title: '1000 PRODUCTS',
      expiryLabel: 'Sep 30, 2026',
      expiresAt: DateTime(2030, 10, 1),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: SizedBox(
            width: 430,
            child: HomeBannerCarousel(
              controller: controller,
              height: 206,
              banners: [campaign],
              onBannerTap: (banner) {
                openedSaleId = banner.campaignSaleId ?? 0;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('SHOP SALE'), findsOneWidget);
    await tester.tap(find.text('SHOP SALE'));
    expect(openedSaleId, 42);
  });
}
