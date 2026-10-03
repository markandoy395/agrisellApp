import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_gcash_settings_widgets.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_toolbar.dart';

void main() {
  testWidgets('GCash visibility changes only when the toggle is pressed', (
    tester,
  ) async {
    final textController = TextEditingController(text: '09123456789');
    addTearDown(textController.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerGcashSettingsField(
            controller: textController,
            label: 'GCash number',
            icon: Icons.phone,
            enabled: true,
            isPhone: true,
            onChanged: () {},
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
    await tester.tap(find.byTooltip('Show GCash number'));
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isFalse,
    );
    expect(textController.text, '09123456789');
  });

  testWidgets('rider search clears only after pressing its clear button', (
    tester,
  ) async {
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(),
    );
    addTearDown(controller.dispose);
    controller.setSearchText('tomatoes');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RiderRequestToolbar(controller: controller)),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(controller.searchText, 'tomatoes');
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    expect(controller.searchText, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });
}
