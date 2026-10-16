import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/utils/rider_delivery_message.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_confirmation_footer.dart';

void main() {
  testWidgets(
    'delivery errors wrap fully, remain readable, and can be dismissed',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: Scaffold(
            bottomNavigationBar: const SizedBox(height: 90),
            body: Builder(
              builder: (value) {
                context = value;
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      const message =
          'The delivery update could not be completed. Refresh this delivery and try again.';
      showRiderDeliveryMessage(context, message);
      await tester.pumpAndSettle();
      final text = find.text(message);
      expect(
        tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
        isFalse,
      );
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).duration,
        const Duration(seconds: 6),
      );
      expect(
        tester.getBottomRight(find.byType(SingleChildScrollView)).dy,
        lessThan(700),
      );
      expect(
        tester.widget<SnackBar>(find.byType(SnackBar)).behavior,
        SnackBarBehavior.fixed,
      );
      expect(
        tester.getBottomRight(find.byType(SnackBar)).dy,
        lessThanOrEqualTo(610),
      );
      await tester.pump(const Duration(seconds: 3));
      expect(text, findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(text, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  for (final size in [const Size(320, 640), const Size(640, 240)]) {
    testWidgets('message height is bounded and leaves footer usable at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      late BuildContext context;
      var submitted = false;
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
            bottomNavigationBar: RiderDeliveryConfirmationFooter(
              isSubmitting: false,
              onSubmit: () => submitted = true,
            ),
            body: Builder(
              builder: (value) {
                context = value;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      showRiderDeliveryMessage(
        context,
        List.filled(
          20,
          'Capture delivery evidence before completing delivery.',
        ).join(' '),
      );
      await tester.pumpAndSettle();
      final snack = find.byType(SnackBar);
      final footer = find.byType(RiderDeliveryConfirmationFooter);
      expect(tester.getSize(snack).height, lessThan(size.height * 0.5));
      expect(
        tester.getBottomRight(snack).dy,
        lessThanOrEqualTo(tester.getTopLeft(footer).dy),
      );
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: snack, matching: find.byType(Scrollable)),
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      scroll.position.jumpTo(scroll.position.maxScrollExtent);
      await tester.pump();
      await tester.tap(find.text('Complete delivery'));
      expect(submitted, isTrue);
      tester.view.physicalSize = Size(size.height, size.width);
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(SingleChildScrollView)).height,
        lessThanOrEqualTo(size.width * 0.25),
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(snack, findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
