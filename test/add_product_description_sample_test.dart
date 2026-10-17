import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/products/domain/product_description_samples.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';
import 'package:agresell_app/features/shared/products/domain/product_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every product category has many concise sample descriptions', () {
    for (final category in ProductCategories.values) {
      final samples = ProductDescriptionSamples.samplesFor(category);
      expect(samples.length, greaterThanOrEqualTo(10));
      expect(samples.toSet().length, samples.length);
      for (final sample in samples) {
        expect(sample.trim(), isNotEmpty);
        expect(sample.length, lessThanOrEqualTo(300));
      }
    }
  });

  testWidgets(
    'description sample button inside input field cycles category descriptions on each click',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AgrisellTheme.light,
          home: const AddProductScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final categoryDropdown = find
          .byType(DropdownButtonFormField<String>)
          .first;
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ProductCategories.vegetables).last);
      await tester.pumpAndSettle();

      final button = find.byKey(const Key('description-sample-button'));
      expect(button, findsOneWidget);

      final vegetableSamples = ProductDescriptionSamples.samplesFor(
        ProductCategories.vegetables,
      );
      String? previousDescription;
      for (var i = 0; i < 6; i++) {
        await tester.tap(button);
        await tester.pump();
        final descriptionField = tester.widget<TextField>(
          find.ancestor(of: button, matching: find.byType(TextField)),
        );
        final current = descriptionField.controller!.text;
        expect(current, isNotEmpty);
        expect(vegetableSamples, contains(current));
        expect(current, isNot(equals(previousDescription)));
        previousDescription = current;
      }

      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(ProductCategories.spices).last);
      await tester.pumpAndSettle();

      final spiceSamples = ProductDescriptionSamples.samplesFor(
        ProductCategories.spices,
      );
      final descriptionFieldAfterSwitch = tester.widget<TextField>(
        find.ancestor(of: button, matching: find.byType(TextField)),
      );
      final spiceFirst = descriptionFieldAfterSwitch.controller!.text;
      expect(spiceSamples, contains(spiceFirst));

      await tester.tap(button);
      await tester.pump();
      final spiceSecond = descriptionFieldAfterSwitch.controller!.text;
      expect(spiceSamples, contains(spiceSecond));
      expect(spiceSecond, isNot(equals(spiceFirst)));
    },
  );
}
