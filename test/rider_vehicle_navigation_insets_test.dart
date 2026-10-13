import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_vehicle_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bottomInset in [24.0, 48.0]) {
    testWidgets('vehicle action clears device navigation inset $bottomInset', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      var edited = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(320, 640),
              padding: EdgeInsets.only(bottom: bottomInset),
              viewPadding: EdgeInsets.only(bottom: bottomInset),
              textScaler: const TextScaler.linear(1.5),
            ),
            child: Scaffold(
              appBar: AppBar(title: const Text('Vehicle details')),
              body: RiderVehicleContent(
                children: [
                  for (var index = 0; index < 10; index++)
                    SizedBox(height: 100, child: Text('Vehicle field $index')),
                  FilledButton(
                    onPressed: () => edited = true,
                    child: const Text('Edit vehicle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      final list = tester.state<ScrollableState>(find.byType(Scrollable));
      list.position.jumpTo(list.position.maxScrollExtent);
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Edit vehicle');
      expect(
        tester.getBottomRight(button).dy,
        lessThanOrEqualTo(640 - bottomInset - 14),
      );
      expect(
        tester.getBottomRight(find.byType(ListView)).dy,
        640 - bottomInset,
      );
      await tester.tap(button);
      expect(edited, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
