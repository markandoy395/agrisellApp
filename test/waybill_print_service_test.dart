import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/waybills/domain/delivery_waybill.dart';
import 'package:agresell_app/features/shared/waybills/services/waybill_html_service.dart';
import 'package:agresell_app/features/shared/waybills/presentation/widgets/waybill_sheet_actions.dart';
import 'support/rider_completion_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('agrisell/waybill_print');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'Android passes escaped HTML directly to the native print channel',
    () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return true;
      });
      final waybill = DeliveryWaybill.fromRiderDelivery(
        completionRequest(),
        riderName: 'Rider',
        riderContact: '',
      );
      expect(await WaybillHtmlService.openPrintableWaybill(waybill), isTrue);
      expect(received?.method, 'printHtml');
      final arguments = received!.arguments as Map;
      expect(arguments['jobName'], 'AgriSell Waybill ${waybill.orderId}');
      final html = await WaybillHtmlService.generateHtml(waybill);
      expect(arguments['html'], html);
      expect(html, isNot(contains('<style>')));
      expect(html, contains('await document.fonts.ready'));
      final stylesheet = RegExp('href="([^"]+)"').firstMatch(html)!.group(1)!;
      final css = Uri.parse(stylesheet).data!.contentAsString();
      expect(css, contains('14px Poppins, sans-serif'));
      expect(css, isNot(contains('monospace')));
      expect(css, isNot(contains('{{POPPINS_')));
      final fontUrls = RegExp('url\\("([^"]+)"\\)').allMatches(css);
      expect(fontUrls, hasLength(4));
      for (final match in fontUrls) {
        final data = Uri.parse(match.group(1)!).data!;
        expect(data.mimeType, 'font/ttf');
        // TrueType sfnt header proves the document contains font bytes.
        expect(data.contentAsBytes().take(4), [0, 1, 0, 0]);
      }
      expect(arguments.containsKey('path'), isFalse);
    },
  );

  test(
    'Android never falls back to exposing a file URI on native failure',
    () async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        throw PlatformException(code: 'print_unavailable');
      });
      await expectLater(
        WaybillHtmlService.openPrintableWaybill(
          DeliveryWaybill.fromRiderDelivery(
            completionRequest(),
            riderName: 'Rider',
            riderContact: '',
          ),
        ),
        throwsA(isA<PlatformException>()),
      );
    },
  );

  for (final throws in [false, true]) {
    testWidgets('print failure gives a short safe message; throws=$throws', (
      tester,
    ) async {
      messenger.setMockMethodCallHandler(channel, (_) async {
        if (throws) {
          throw PlatformException(
            code: 'print_unavailable',
            message: 'PRIVATE STACK TRACE file:///data/user/private.html',
          );
        }
        return false;
      });
      final waybill = DeliveryWaybill.fromRiderDelivery(
        completionRequest(),
        riderName: 'Rider',
        riderContact: '',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    WaybillSheetActions.printWaybill(context, waybill),
                child: const Text('Print'),
              ),
            ),
          ),
        ),
      );
      // Font assets load through real asynchronous bundle I/O.
      await tester.runAsync(() async {
        await tester.tap(find.text('Print'));
        await WaybillHtmlService.generateHtml(waybill);
      });
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Could not open the print dialog. Close the waybill and try again.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('PRIVATE STACK'), findsNothing);
      expect(find.textContaining('file:///'), findsNothing);
      expect(tester.takeException(), isNull);
      debugDefaultTargetPlatformOverride = null;
    });
  }
}
