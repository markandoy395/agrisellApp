import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_categories_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer category card keeps all five image categories', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(body: HomeCategoriesCard()),
      ),
    );
    await tester.pumpAndSettle();

    for (final category in const [
      'Vegetables',
      'Fruits',
      'Nuts',
      'Fruit Trees',
      'Spices',
    ]) {
      expect(find.text(category), findsOneWidget);
    }
    expect(find.byType(ResponsiveAssetImage), findsNWidgets(5));
    expect(tester.takeException(), isNull);
  });
}
