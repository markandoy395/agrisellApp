import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/widgets/app_snack_bar_panel.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';

void main() {
  for (final resize in [true, false]) {
    for (final keyboardInset in [0.0, 240.0]) {
      testWidgets(
        'message stays on screen with keyboard $keyboardInset resize=$resize',
        (tester) async {
          await tester.binding.setSurfaceSize(const Size(384, 600));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          final messenger = GlobalKey<ScaffoldMessengerState>();
          await tester.pumpWidget(
            MaterialApp(
              scaffoldMessengerKey: messenger,
              theme: AgrisellTheme.light,
              home: MediaQuery(
                data: MediaQueryData(
                  size: const Size(384, 600),
                  viewInsets: EdgeInsets.only(bottom: keyboardInset),
                  padding: EdgeInsets.only(bottom: keyboardInset == 0 ? 24 : 0),
                  textScaler: const TextScaler.linear(1.5),
                ),
                child: Scaffold(
                  resizeToAvoidBottomInset: resize,
                  extendBody: true,
                  bottomNavigationBar: const SizedBox(height: 108),
                  floatingActionButton: const SizedBox(width: 56, height: 300),
                  body: const SizedBox.expand(),
                ),
              ),
            ),
          );
          messenger.currentState!.showAppSnackBar(
            const SnackBar(
              content: Text('Current GPS location is unavailable. Try again.'),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final message = find.text(
            'Current GPS location is unavailable. Try again.',
          );
          expect(tester.getTopLeft(message).dy, greaterThanOrEqualTo(0));
          expect(
            tester.getBottomRight(message).dy,
            lessThanOrEqualTo(600 - keyboardInset),
          );
          messenger.currentState!.removeCurrentSnackBar();
          messenger.currentState!.showSnackBar(
            const SnackBar(content: Text('Map message using theme defaults')),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(
            tester.getTopLeft(find.text('Map message using theme defaults')).dy,
            greaterThanOrEqualTo(0),
          );
        },
      );
    }
  }

  testWidgets(
    'app SnackBar reserves bottom space and replaces the current one',
    (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (builderContext) {
                context = builderContext;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(const SnackBar(content: Text('First message')));
      await tester.pump();
      ScaffoldMessenger.of(
        context,
      ).showAppSnackBar(const SnackBar(content: Text('Latest message')));
      await tester.pumpAndSettle();

      expect(find.text('First message'), findsNothing);
      expect(find.text('Latest message'), findsOneWidget);
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.fixed);
      expect(snackBar.duration, const Duration(seconds: 2));
      expect(snackBar.margin, isNull);
      expect(snackBar.width, isNull);
      expect(find.byType(AppSnackBarPanel), findsOneWidget);
      expect(snackBar.backgroundColor, Colors.transparent);
    },
  );

  testWidgets('app SnackBar preserves non-persistent actions', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(
        content: const Text('Removed'),
        persist: false,
        action: SnackBarAction(label: 'Undo', onPressed: () {}),
      ),
      duration: const Duration(milliseconds: 1500),
    );
    await tester.pumpAndSettle();

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.persist, isFalse);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Removed'), findsNothing);
  });

  testWidgets('shared action remains tappable and closes with action reason', (
    tester,
  ) async {
    final messenger = GlobalKey<ScaffoldMessengerState>();
    var undone = false;
    await tester.pumpWidget(
      MaterialApp(
        scaffoldMessengerKey: messenger,
        home: const Scaffold(body: SizedBox.expand()),
      ),
    );
    final controller = messenger.currentState!.showAppSnackBar(
      SnackBar(
        content: const Text('Removed'),
        action: SnackBarAction(label: 'Undo', onPressed: () => undone = true),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.widget<SnackBar>(find.byType(SnackBar)).persist, isTrue);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(undone, isTrue);
    expect(await controller.closed, SnackBarClosedReason.action);
  });
}
