import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/core/widgets/responsive_asset_image.dart';
import 'package:agresell_app/features/shared/products/presentation/widgets/home_categories_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('buyer category card keeps all five image categories', (
    tester,
  ) async {
    String? selected;
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
          body: HomeCategoriesCard(onSelected: (value) => selected = value),
        ),
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
      final paragraph = tester.renderObject<RenderParagraph>(
        find.descendant(
          of: find.text(category),
          matching: find.byType(RichText),
        ),
      );
      expect(paragraph.didExceedMaxLines, isFalse);
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: category.length),
      );
      expect(boxes.map((box) => box.top).toSet(), hasLength(1));
    }
    expect(find.byType(ResponsiveAssetImage), findsNWidgets(5));
    await tester.ensureVisible(find.text('Spices'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spices'));
    expect(selected, 'Spices');
    expect(tester.takeException(), isNull);
  });
}
