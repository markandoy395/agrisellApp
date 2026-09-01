import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/buyer_home_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer home shows compact categories without a card background', (
    tester,
  ) async {
    String? selectedCategory;

    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: BuyerHomeCategories(
            selectedCategory: 'Vegetables',
            onSelected: (category) => selectedCategory = category,
          ),
        ),
      ),
    );

    expect(find.text('Categories'), findsNothing);
    expect(find.text('Show all'), findsOneWidget);
    expect(find.byType(ResponsiveAssetImage), findsNWidgets(5));
    expect(find.byType(Card), findsNothing);

    await tester.ensureVisible(find.text('Show all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all'));
    expect(selectedCategory, 'All');
    expect(tester.takeException(), isNull);
  });
}
