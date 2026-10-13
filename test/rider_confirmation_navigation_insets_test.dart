import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_confirmation_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final navigationInset in [24.0, 48.0]) {
    for (final keyboardInset in [0.0, 280.0]) {
      testWidgets(
        'confirmation clears navigation $navigationInset and keyboard $keyboardInset',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(320, 640));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          var submitted = false;
          await tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(320, 640),
                  padding: EdgeInsets.only(
                    bottom: keyboardInset == 0 ? navigationInset : 0,
                  ),
                  viewPadding: EdgeInsets.only(bottom: navigationInset),
                  viewInsets: EdgeInsets.only(bottom: keyboardInset),
                  textScaler: const TextScaler.linear(1.5),
                ),
                child: Scaffold(
                  resizeToAvoidBottomInset: false,
                  body: Column(
                    children: [
                      const SizedBox(
                        height: 90,
                        child: Text('Confirm delivery'),
                      ),
                      Expanded(
                        child: RiderDeliveryConfirmationContent(
                          child: Column(
                            children: [
                              for (var index = 0; index < 10; index++)
                                SizedBox(
                                  height: 100,
                                  child: Text('Proof $index'),
                                ),
                              FilledButton(
                                onPressed: () => submitted = true,
                                child: const Text('Complete delivery'),
                              ),
                            ],
                          ),
                        ),
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
          final obstruction = keyboardInset == 0
              ? navigationInset
              : keyboardInset;
          final button = find.widgetWithText(FilledButton, 'Complete delivery');
          expect(
            tester.getBottomRight(button).dy,
            lessThanOrEqualTo(640 - obstruction - 28),
          );
          expect(
            tester.getBottomRight(find.byType(ListView)).dy,
            640 - obstruction,
          );
          await tester.tap(button);
          expect(submitted, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
