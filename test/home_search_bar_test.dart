import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('rotates search hints without changing the buyer query', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: HomeSearchBar(
            controller: controller,
            suggestions: const ['Mango', 'Lettuce'],
            onChanged: (_) {},
            onFilterTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Search in AgriSell'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Search in AgriSell'), findsNothing);
    expect(controller.text, isEmpty);

    await tester.enterText(
      find.byKey(const ValueKey('home-product-search')),
      'tomato',
    );
    await tester.pump(const Duration(seconds: 3));

    expect(controller.text, 'tomato');
  });
}
