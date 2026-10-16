import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_pickup_confirmation_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_pickup_problem_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_pickup_proof_tile.dart';
import 'support/rider_pickup_design_fixture.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    Directory('build/rider_pickup_test').createSync(recursive: true);
    await File(
      'assets/images/vege.jpeg',
    ).copy('build/rider_pickup_test/proof.jpg');
    final font = FontLoader('Poppins');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      font.addFont(rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'));
    }
    await font.load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
  });
  for (final width in [320.0, 430.0]) {
    testWidgets(
      'pickup reference at $width retains draft, proofs, checks and fixed actions',
      (tester) async {
        _size(tester, width);
        final fixture = await PickupDesignFixture.create();
        final boundary = GlobalKey();
        await tester.pumpWidget(
          _host(fixture, boundary, textScale: width == 320 ? 1.4 : 1),
        );
        await tester.pumpAndSettle();
        expect(find.text('Confirm pickup'), findsOneWidget);
        expect(find.textContaining('GPS ready'), findsOneWidget);
        final complete = find.widgetWithText(FilledButton, 'Complete pickup');
        final actionPosition = tester.getTopLeft(complete);
        await _capture(tester, boundary, 'pickup_${width.toInt()}_top');
        await _scrollTo(tester, _field('Pickup confirmation code'));
        await tester.enterText(_field('Pickup confirmation code'), '246810');
        await tester.tap(find.byTooltip('Show pickup code'));
        await tester.pump();
        expect(
          tester
              .widget<TextField>(_field('Pickup confirmation code'))
              .obscureText,
          isFalse,
        );
        await tester.enterText(_field('QR scan result'), 'pickup-qr');
        await tester.pump(const Duration(seconds: 2));
        expect(
          tester
              .widget<TextField>(_field('Pickup confirmation code'))
              .controller!
              .text,
          '246810',
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await _scrollTo(tester, find.text('Add product photo proof'));
        final photoTile = find.byType(RiderPickupProofTile).first;
        await tester.runAsync(
          () => precacheImage(
            ResizeImage(
              FileImage(File('build/rider_pickup_test/proof.jpg')),
              width: 270,
            ),
            tester.element(photoTile),
          ),
        );
        await tester.tap(find.text('Add product photo proof'));
        await tester.pumpAndSettle();
        expect(fixture.storage.captureCalls, 1);
        expect(find.text('product photo saved'), findsOneWidget);
        expect(
          tester
              .widget<RawImage>(
                find.descendant(of: photoTile, matching: find.byType(RawImage)),
              )
              .image,
          isNotNull,
        );
        await _capture(tester, boundary, 'pickup_${width.toInt()}_proofs');
        await tester.tap(find.byTooltip('Remove product photo from pickup'));
        await tester.pumpAndSettle();
        expect(find.text('Add product photo proof'), findsOneWidget);
        await tester.tap(find.text('Add product photo proof'));
        await tester.pumpAndSettle();
        await _scrollTo(tester, find.text('Product condition checklist'));
        expect(tester.getTopLeft(complete), actionPosition);
        await tester.tap(complete);
        await tester.pumpAndSettle();
        await _scrollTo(
          tester,
          find.text('Complete all 8 product condition checklist items.'),
          fallback: find.textContaining(
            'Complete all 8 product condition checklist items.',
          ),
        );
        expect(
          find.textContaining(
            'Complete all 8 product condition checklist items.',
          ),
          findsOneWidget,
        );
        final saved = fixture.controller.recoveryDataFor(
          'pickupConfirmation:${fixture.request.id}',
        );
        expect(saved.containsKey('confirmationCode'), isFalse);
        expect(saved.containsKey('qrPayload'), isFalse);
        await _capture(tester, boundary, 'pickup_${width.toInt()}_checks');
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets(
    'signed receipt proof opens camera instead of saving an attestation',
    (tester) async {
      _size(tester, 320);
      final fixture = await PickupDesignFixture.create();
      await tester.pumpWidget(_host(fixture, GlobalKey()));
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('Add signed receipt photo proof'));
      await tester.tap(find.text('Add signed receipt photo proof'));
      await tester.pumpAndSettle();
      expect(fixture.storage.captureCalls, 1);
      expect(find.text('signed receipt photo saved'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'problem sheet validates notes, selects all reasons and fits keyboard',
    (tester) async {
      _size(tester, 320);
      PickupProblemDraft? draft;
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          builder: (context, child) =>
              RepaintBoundary(key: boundary, child: child),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  draft = await showRiderPickupProblemDialog(context);
                },
                child: const Text('Open problem'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open problem'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save problem'));
      await tester.pump();
      expect(find.text('Add notes of up to 500 characters.'), findsOneWidget);
      await _scrollTo(tester, find.text('Farmer unavailable'));
      await tester.tap(find.text('Farmer unavailable'));
      await _scrollTo(tester, _field('Notes *'));
      await tester.enterText(
        _field('Notes *'),
        'Farmer unavailable at the pickup point.',
      );
      await tester.pumpAndSettle();
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await _capture(tester, boundary, 'problem_sheet');
      await tester.tap(find.text('Save problem'));
      await tester.pumpAndSettle();
      expect(draft?.kind, PickupProblemKind.farmerUnavailable);
      expect(draft?.notes, 'Farmer unavailable at the pickup point.');
    },
  );
  testWidgets(
    'complete pickup submits actual required values and returns success',
    (tester) async {
      _size(tester, 430);
      final fixture = await PickupDesignFixture.create();
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => _screen(fixture)),
                  );
                },
                child: const Text('Open pickup'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open pickup'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, _field('Pickup confirmation code'));
      await tester.enterText(_field('Pickup confirmation code'), '246810');
      await tester.enterText(_field('QR scan result'), 'pickup-qr');
      await _scrollTo(tester, find.text('Add product photo proof'));
      await tester.tap(find.text('Add product photo proof'));
      await tester.pumpAndSettle();
      for (final label in [
        'Correct product',
        'Correct quantity',
        'Correct weight',
        'Packaging is secure',
        'Product is not visibly damaged',
        'Product matches the request',
        'Product fits the vehicle',
        'Handling instructions received',
      ]) {
        await _scrollTo(tester, find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.widgetWithText(FilledButton, 'Complete pickup'));
      await tester.pumpAndSettle();
      expect(
        result,
        isTrue,
        reason: tester
            .widgetList<Text>(find.byType(Text))
            .map((text) => text.data)
            .join(' | '),
      );
      expect(
        fixture.repository
            .pickupRecordFor(fixture.request.id)
            ?.checklist
            .allItemsChecked,
        isTrue,
      );
      expect(
        fixture.controller.activeDeliveryStatus,
        DeliveryStatus.productPickedUp,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'saved pickup problem shows success feedback and can be dismissed',
    (tester) async {
      _size(tester, 430);
      final fixture = await PickupDesignFixture.create();
      fixture.storage.cancelCapture = true;
      final boundary = GlobalKey();
      await tester.pumpWidget(_host(fixture, boundary));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Report pickup problem'));
      await tester.pumpAndSettle();
      await _scrollTo(tester, _field('Notes *'));
      await tester.enterText(
        _field('Notes *'),
        'Product is not ready for pickup.',
      );
      await tester.tap(find.text('Save problem'));
      await tester.pumpAndSettle();
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      await _scrollTo(tester, find.text('Problem saved'));
      expect(
        find.text('Contact support before continuing pickup.'),
        findsOneWidget,
      );
      await _capture(tester, boundary, 'problem_saved');
      await tester.tap(find.byTooltip('Dismiss saved problem'));
      await tester.pumpAndSettle();
      expect(find.text('Problem saved'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Widget _host(
  PickupDesignFixture fixture,
  GlobalKey key, {
  double textScale = 1,
}) => MaterialApp(
  theme: AgrisellTheme.light,
  builder: (context, child) => RepaintBoundary(
    key: key,
    child: MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
  ),
  home: _screen(fixture),
);
Widget _screen(PickupDesignFixture fixture) => RiderPickupConfirmationScreen(
  request: fixture.request,
  riderId: 'rider-a',
  controller: fixture.controller,
  locationController: fixture.location,
  proofStorage: fixture.storage,
);
Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);
Future<void> _scrollTo(
  WidgetTester tester,
  Finder finder, {
  Finder? fallback,
}) async {
  final target = fallback ?? finder;
  await tester.scrollUntilVisible(
    target,
    160,
    scrollable: find.byType(RiderPickupProblemDialog).evaluate().isEmpty
        ? find.byType(Scrollable).first
        : find
              .descendant(
                of: find.byType(RiderPickupProblemDialog),
                matching: find.byType(Scrollable),
              )
              .first,
  );
  await Scrollable.ensureVisible(tester.element(target), alignment: .5);
  await tester.pumpAndSettle();
}

void _size(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 844);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/rider_pickup_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}
