import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_profile_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_overview.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_empty_state.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_document_card.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_vehicle_overview.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_password_dialog.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'support/rider_test_models.dart';

void main() {
  setUpAll(() async {
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
    testWidgets('profile overview and settings are readable at $width', (
      tester,
    ) async {
      _size(tester, width);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          builder: (context, child) => RepaintBoundary(
            key: boundary,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(width == 320 ? 1.4 : 1)),
              child: child!,
            ),
          ),
          home: RiderProfileScreen(profile: verifiedRiderProfile()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Verified Rider'), findsOneWidget);
      await _capture(tester, boundary, 'overview_${width.toInt()}');
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Edit rider profile'), findsOneWidget);
      await _capture(tester, boundary, 'settings_${width.toInt()}');
      await tester.scrollUntilVisible(find.text('Logout'), 250);
      expect(find.text('Switch account'), findsOneWidget);
      await tester.tap(find.byTooltip('Close settings'));
      await tester.pumpAndSettle();
      expect(find.text('Verified Rider'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('overview activity and edit actions retain callbacks', (
    tester,
  ) async {
    _size(tester, 430);
    var earnings = 0;
    var history = 0;
    var ratings = 0;
    var edit = 0;
    var vehicle = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: RiderProfileOverview(
            profile: verifiedRiderProfile(),
            performance: const RiderRatingsSummary(
              averageRating: 4.8,
              completedDeliveries: 120,
              onTimeDeliveryRate: 96,
            ),
            onEarnings: () => earnings++,
            onHistory: () => history++,
            onRatings: () => ratings++,
            onEdit: () => edit++,
            onVehicle: () => vehicle++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Earnings'), 250);
    await tester.tap(find.text('Earnings'));
    await tester.tap(find.text('Delivery history'));
    await tester.tap(find.text('Ratings & reviews'));
    expect([earnings, history, ratings], [1, 1, 1]);
    await tester.scrollUntilVisible(find.text('Rider information'), 250);
    await tester.tap(find.text('Edit').first);
    expect(edit, 1);
    await tester.scrollUntilVisible(find.text('Vehicle credentials'), 250);
    await tester.ensureVisible(find.text('Edit').last);
    await tester.tap(find.text('Edit').last);
    expect(vehicle, 1);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'document types use real verification status and available dates',
    (tester) async {
      _size(tester, 430);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RepaintBoundary(
              key: boundary,
              child: ListView(
                children: [
                  for (final type in RiderDocumentType.values)
                    RiderDocumentCard(
                      document: RiderDocument(
                        documentId: type.name,
                        riderId: 'rider-1',
                        documentType: type,
                        filePath: '',
                        verificationStatus: type == RiderDocumentType.vehicleOr
                            ? RiderDocumentVerificationStatus.pending
                            : RiderDocumentVerificationStatus.verified,
                        createdAt: type == RiderDocumentType.vehicleOr
                            ? null
                            : DateTime(2026, 10, 15),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text("Driver's license"), findsOneWidget);
      await _capture(tester, boundary, 'documents');
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('vehicle and empty states fit large text without sample data', (
    tester,
  ) async {
    _size(tester, 320);
    var edits = 0;
    final boundary = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.4)),
          child: child!,
        ),
        home: Scaffold(
          body: RepaintBoundary(
            key: boundary,
            child: ListView(
              children: [
                RiderVehicleOverview(
                  vehicle: const RiderVehicle(
                    vehicleId: 'v1',
                    riderId: 'r1',
                    vehicleType: 'Motorcycle',
                    vehicleModel: 'Saved model',
                    vehicleColor: 'Black',
                    plateNumber: 'ABC 1234',
                    capacityKg: 30,
                  ),
                  onEdit: () => edits++,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit vehicle'));
    expect(edits, 1);
    await _capture(tester, boundary, 'vehicle');
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const Scaffold(body: RiderProfileEmptyState(logistics: true)),
      ),
    );
    expect(find.text('No logistics company assigned'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'password form validates and toggles visibility without losing text',
    (tester) async {
      _size(tester, 320);
      RiderPasswordChange? result;
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
                  result = await showRiderPasswordChangeDialog(context);
                },
                child: const Text('Open password'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Update password'));
      await tester.pump();
      expect(result, isNull);
      await tester.enterText(find.byType(TextField).at(0), 'Current123!');
      await tester.enterText(find.byType(TextField).at(1), 'Replacement123!');
      await tester.enterText(find.byType(TextField).at(2), 'Replacement123!');
      await tester.tap(find.byTooltip('Show current password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).obscureText,
        isFalse,
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextField>(find.byType(TextField).first)
            .decoration!
            .floatingLabelBehavior,
        FloatingLabelBehavior.auto,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      await _capture(tester, boundary, 'password');
      await tester.ensureVisible(find.text('Update password'));
      await tester.tap(find.text('Update password'));
      await tester.pumpAndSettle();
      expect(result?.newPassword, 'Replacement123!');
      expect(tester.takeException(), isNull);
    },
  );
}

void _size(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Future<void> _capture(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  boundary.markNeedsPaint();
  await tester.pump();
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('build/rider_profile_previews')
      ..createSync(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
    image.dispose();
  });
}
