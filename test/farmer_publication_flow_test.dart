import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/products/presentation/screens/add_product_screen.dart';
import 'package:agresell_app/features/farmer/products/domain/farmer_dashboard_product.dart';

void main() {
  testWidgets(
    'failed publication retains draft; retry uses the same key and blocks duplicate taps',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 1500);
      addTearDown(tester.view.reset);
      final first = Completer<FarmerDashboardProduct?>();
      final keys = <String>[];
      FarmerDashboardProduct? returned;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  returned = await Navigator.of(context)
                      .push<FarmerDashboardProduct>(
                        MaterialPageRoute(
                          builder: (_) => AddProductScreen(
                            initialPhotoBytes: base64Decode(
                              'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
                            ),
                            onPublish: (_, product, key) {
                              keys.add(key);
                              return keys.length == 1
                                  ? first.future
                                  : Future.value(
                                      product.copyWith(
                                        commodityId: 42,
                                        farmId: 7,
                                      ),
                                    );
                            },
                          ),
                        ),
                      );
                },
                child: const Text('Open listing'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open listing'));
      await tester.pumpAndSettle();
      final dropdown = find.byType(DropdownButtonFormField<String>).first;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fruit Trees').last);
      await tester.pumpAndSettle();
      for (final entry in <int, String>{
        0: 'Mango seedling',
        1: 'Healthy grafted seedling',
        2: '100',
        3: '10',
        4: '1',
      }.entries) {
        final field = find.byType(TextField).at(entry.key);
        await tester.ensureVisible(field);
        await tester.enterText(field, entry.value);
      }
      await tester.ensureVisible(find.text('Publish Product'));
      await tester.tap(find.text('Publish Product'));
      await tester.pump();
      expect(keys, hasLength(1));
      expect(find.text('Publishing…'), findsOneWidget);
      await tester.tap(find.text('Publishing…'), warnIfMissed: false);
      await tester.pump();
      expect(keys, hasLength(1));
      first.completeError(StateError('connection lost'));
      await tester.pumpAndSettle();
      expect(find.byType(AddProductScreen), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Mango seedling',
      );
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Publish Product'));
      await tester.tap(find.text('Publish Product'));
      await tester.pumpAndSettle();
      expect(keys, hasLength(2));
      expect(keys[1], keys[0]);
      expect(find.byType(AddProductScreen), findsNothing);
      expect(returned?.commodityId, 42);
    },
  );
}
