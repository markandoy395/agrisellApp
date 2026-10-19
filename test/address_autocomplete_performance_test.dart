import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/location/data/psgc_address_service.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/address_autocomplete_field.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/address_suggestion_menu.dart';

void main() {
  testWidgets('parent and keyboard rebuilds retain unchanged menu entries', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    addTearDown(tester.view.resetViewInsets);
    const options = [
      PsgcAddressOption(code: '1', name: 'City One'),
      PsgcAddressOption(code: '2', name: 'City Two'),
    ];
    late StateSetter rebuildParent;
    var places = options;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuildParent = setState;
              return AddressAutocompleteField(
                label: 'City',
                controller: controller,
                options: places,
                onChanged: (_) {},
                onSelected: (_) {},
              );
            },
          ),
        ),
      ),
    );
    List<DropdownMenuEntry<PsgcAddressOption>> entries() => tester
        .widget<AddressSuggestionMenu>(find.byType(AddressSuggestionMenu))
        .entries;
    final original = entries();
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    for (final inset in [100.0, 300.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      rebuildParent(() => places = List.of(options));
      await tester.pump();
      expect(entries(), same(original));
      expect(tester.takeException(), isNull);
    }
    // A real change must invalidate the retained entries.
    rebuildParent(() {
      places = const [PsgcAddressOption(code: '3', name: 'Replacement city')];
    });
    await tester.pump();
    expect(entries().single.value.code, '3');
    await tester.enterText(find.byType(TextField), 'No match');
    await tester.pumpAndSettle();
    expect(entries(), isEmpty);
    expect(tester.takeException(), isNull);
    // A match after an empty result must reopen the suggestions.
    await tester.enterText(find.byType(TextField), 'Replacement');
    await tester.pumpAndSettle();
    expect(find.byType(MenuItemButton), findsOneWidget);
  });

  for (final count in [80, 200, 1800]) {
    testWidgets(
      '$count places render bounded suggestions and remain searchable',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        final options = List.generate(
          count,
          (index) => PsgcAddressOption(
            code: '$index',
            name: 'City $index',
            province: 'Province $index',
          ),
        );
        PsgcAddressOption? selected;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AddressAutocompleteField(
                label: 'City',
                controller: controller,
                options: options,
                onChanged: (_) {},
                onSelected: (value) => selected = value,
              ),
            ),
          ),
        );
        final dropdown = find.byType(AddressSuggestionMenu);
        expect(
          tester.widget<AddressSuggestionMenu>(dropdown).entries.length,
          20,
        );
        final last = count - 1;
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        // A 240px menu builds only the viewport and a small scroll cache,
        // instead of laying out all 20 suggestion buttons intrinsically.
        expect(find.byType(MenuItemButton).evaluate().length, lessThan(20));
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pumpAndSettle();
        await tester.tap(find.text('City 19 \u2014 Province 19'));
        await tester.pumpAndSettle();
        expect(controller.text, 'City 19');
        tester.view.viewInsets = const FakeViewPadding(bottom: 300);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.enterText(find.byType(TextField), 'City $last');
        await tester.pumpAndSettle();
        final entries = tester.widget<AddressSuggestionMenu>(dropdown).entries;
        expect(entries.single.value.code, '$last');
        await tester.tap(find.text('City $last \u2014 Province $last').last);
        await tester.pumpAndSettle();
        expect(selected?.code, '$last');
        expect(controller.text, 'City $last');
      },
    );
  }

  testWidgets(
    'cursor and composing changes do not notify the parent as edits',
    (tester) async {
      final controller = TextEditingController(text: 'Existing city');
      addTearDown(controller.dispose);
      var edits = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressAutocompleteField(
              label: 'City',
              controller: controller,
              options: const [],
              onChanged: (_) => edits++,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      controller.selection = const TextSelection.collapsed(offset: 2);
      controller.value = controller.value.copyWith(
        composing: const TextRange(start: 0, end: 2),
      );
      await tester.pump();
      expect(edits, 0);
      controller.text = 'Manual city';
      await tester.pump();
      expect(edits, 1);
      expect(controller.text, 'Manual city');
    },
  );
}
