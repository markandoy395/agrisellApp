import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/buyer/home/presentation/widgets/home/buyer_home_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
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

    for (final label in ['Vegetables', 'Fruit Trees', 'Show all']) {
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(of: find.text(label), matching: find.byType(RichText)),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: label.length),
      );
      expect(boxes.map((box) => box.top).toSet(), hasLength(1));
    }

    await tester.ensureVisible(find.text('Show all'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all'));
    expect(selectedCategory, 'All');
    expect(tester.takeException(), isNull);
  });
}
