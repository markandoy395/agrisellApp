import 'dart:async';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_registration_submitted_screen.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:agresell_app/features/farmer/registration/presentation/screens/farmer_sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  const phoneChannel = MethodChannel('agrisell/device_phone_number');

  setUp(AuthRegistrationService.instance.clearForTesting);
  tearDown(AuthRegistrationService.instance.clearForTesting);

  testWidgets('verified Farmer recovery resumes at personal information', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const FarmerSignUpScreen(
          initialVerifiedEmail: 'farmer@example.com',
        ),
      ),
    );

    expect(find.text('2 of 3'), findsOneWidget);
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsNothing);
  });

  testWidgets('profile header back button returns to account step', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: const FarmerSignUpScreen(
          initialVerifiedEmail: 'farmer@example.com',
        ),
      ),
    );

    expect(find.text('Tell us more about yourself.'), findsOneWidget);
    expect(
      find.text('Easily find and connect with your contacts.'),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('1 of 3'), findsOneWidget);
    expect(find.text('Account information'), findsOneWidget);
  });

  testWidgets('populated account fields support enlarged device text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(const Size(430, 932));
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.35)),
          child: child!,
        ),
        home: const FarmerSignUpScreen(),
      ),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'farmer@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Password123!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'Password123!',
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Farmer signup validates account details and preserves them back',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: const FarmerSignUpScreen(),
        ),
      );

      expect(find.text('1 of 3'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Email'),
        'farmer@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'Password123!',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirm password'),
        'Password123!',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('2 of 3'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Email'), findsNothing);
      expect(find.widgetWithText(TextField, 'Password'), findsNothing);
      expect(find.widgetWithText(TextField, 'Confirm password'), findsNothing);
      expect(find.text('Sync contact to phone'), findsOneWidget);
      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Female'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Street / address line (manual entry)'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('farmer-gender-female')),
      );
      await tester.tap(find.byKey(const ValueKey('farmer-gender-female')));
      await tester.pump();
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(phoneChannel, (_) async => '+639171234567');
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(phoneChannel, null),
      );
      await tester.ensureVisible(find.text('Sync contact to phone'));
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .singleWhere((field) => field.controller?.text == '09171234567')
            .controller!
            .text,
        '09171234567',
      );
      await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Back'));
      await tester.pumpAndSettle();
      final preservedEmailField = tester
          .widgetList<TextField>(find.byType(TextField))
          .singleWhere(
            (field) => field.controller?.text == 'farmer@example.com',
          );
      expect(preservedEmailField.controller!.text, 'farmer@example.com');
    },
  );

  testWidgets('Farmer signup personal details can be scrolled', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(theme: AgrisellTheme.light, home: const FarmerSignUpScreen()),
    );

    await tester.enterText(
      find.widgetWithText(TextField, 'Email'),
      'farmer@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Password'),
      'Password123!',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm password'),
      'Password123!',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
    await tester.pumpAndSettle();

    final scrollView = find.byKey(
      const PageStorageKey('farmer-signup-step-scroll'),
    );
    final scrollableFinder = find.descendant(
      of: scrollView,
      matching: find.byType(Scrollable),
    );
    final scrollable = tester.state<ScrollableState>(scrollableFinder.first);
    expect(scrollable.position.maxScrollExtent, greaterThan(0));

    await tester.drag(scrollView, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(scrollable.position.pixels, greaterThan(0));
  });

  testWidgets(
    'Submit registration retries hidden GPS capture before validation',
    (tester) async {
      final gps = _FakeGpsGateway(serviceEnabledResponses: [false, true]);
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: FarmerSignUpScreen(gpsGateway: gps),
        ),
      );

      await _enterText(tester, 'Email', 'farmer@example.com');
      await _enterText(tester, 'Password', 'Password123!');
      await _enterText(tester, 'Confirm password', 'Password123!');
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      await _enterText(tester, 'First name', 'Ana');
      await _enterText(tester, 'Last name', 'Reyes');
      await _enterText(tester, 'Phone number (09XXXXXXXXX)', '09171234567');
      final birthDate = find.widgetWithText(TextField, 'Date of birth');
      await tester.ensureVisible(birthDate);
      await tester.tap(birthDate);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Continue'));
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('3 of 3'), findsOneWidget);
      expect(gps.locationSettingsOpenCalls, 1);
      expect(gps.currentPositionCalls, 0);

      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Submit registration'),
      );
      await tester.tap(
        find.widgetWithText(FilledButton, 'Submit registration'),
      );
      await tester.pumpAndSettle();

      expect(gps.currentPositionCalls, 1);
      expect(
        find.text(
          'Allow location access so we can capture your farm location.',
        ),
        findsNothing,
      );
    },
  );

  testWidgets('Farmer submitted screen explains admin confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerRegistrationSubmittedScreen(reference: 'farmer-123'),
      ),
    );

    expect(find.text('Farmer registration submitted'), findsOneWidget);
    expect(find.text('Reference: farmer-123'), findsOneWidget);
    expect(
      find.text(
        'Your farm and identity details were submitted. Please wait for admin confirmation before selling products.',
      ),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(FilledButton, 'Return to login'),
      findsOneWidget,
    );
  });
}

Future<void> _enterText(WidgetTester tester, String label, String value) async {
  final field = find.widgetWithText(TextField, label);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Position _position() => Position(
  longitude: 124.6472,
  latitude: 8.4822,
  timestamp: DateTime.now(),
  accuracy: 8,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

class _FakeGpsGateway implements GpsLocationGateway {
  _FakeGpsGateway({required List<bool> serviceEnabledResponses})
    : _serviceEnabledResponses = List<bool>.from(serviceEnabledResponses);

  final List<bool> _serviceEnabledResponses;
  var currentPositionCalls = 0;
  var locationSettingsOpenCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> currentPosition({required LocationSettings settings}) async {
    currentPositionCalls++;
    return _position();
  }

  @override
  Future<LocationAccuracyStatus> getAccuracyStatus() async =>
      LocationAccuracyStatus.precise;

  @override
  Future<bool> isServiceEnabled() async => _serviceEnabledResponses.isEmpty
      ? true
      : _serviceEnabledResponses.removeAt(0);

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsOpenCalls++;
    return true;
  }

  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      const Stream<Position>.empty();

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
