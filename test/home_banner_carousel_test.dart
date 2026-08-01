import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_banner_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
              child: HomeBannerCarousel(controller: controller, height: 206),
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
    expect(find.text('VEGETABLE\nPRODUCT'), findsOneWidget);
    expect(
      find.bySemanticsLabel('VEGETABLE\nPRODUCT promotion'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
