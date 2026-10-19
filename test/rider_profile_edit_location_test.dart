import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_dialog.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_profile_edit_form_fields.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'support/rider_test_models.dart';

void main() {
  testWidgets('rider profile edit captures exact GPS when saved', (
    tester,
  ) async {
    RiderProfile? savedProfile;
    final gps = _FakeGpsGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  savedProfile = await showRiderProfileEditDialog(
                    context,
                    _profile(),
                    gpsGateway: gps,
                  );
                },
                child: const Text('Edit rider'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edit rider'));
    await tester.pumpAndSettle();

    expect(find.text('Map pin'), findsNothing);
    expect(find.text('Tap to pin your registered address'), findsNothing);
    expect(
      find.text(
        'Use your official Philippine address. We will capture your exact GPS location when you save.',
      ),
      findsOneWidget,
    );

    // Address edits and keyboard animation must keep the whole form stable.
    final formFinder = find.byType(RiderProfileEditFormFields);
    final form = tester.widget<RiderProfileEditFormFields>(formFinder);
    form.onPsgcChanged();
    await tester.pump();
    expect(tester.widget(formFinder), same(form));
    addTearDown(tester.view.resetViewInsets);
    for (final inset in [100.0, 300.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pumpAndSettle();
      expect(tester.widget(formFinder), same(form));
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.widgetWithText(FilledButton, 'Save changes'));
    await tester.pumpAndSettle();

    expect(gps.currentPositionCalls, 1);
    expect(savedProfile?.gpsLatitude, 8.4822);
    expect(savedProfile?.gpsLongitude, 124.6472);
  });
}

RiderProfile _profile() => verifiedRiderProfile().copyWith(
  addressLine: '12 Rizal Street',
  barangay: 'Cogon',
  cityMunicipality: 'Cagayan de Oro City',
  province: 'Misamis Oriental',
  postalCode: '9000',
  address:
      '12 Rizal Street, Barangay Cogon, Cagayan de Oro City, Misamis Oriental, 9000, Philippines',
);

Position _position() => Position(
  longitude: 124.6472,
  latitude: 8.4822,
  timestamp: DateTime.utc(2026, 8, 11, 2, 30),
  accuracy: 8,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

class _FakeGpsGateway implements GpsLocationGateway {
  var currentPositionCalls = 0;

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
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<bool> openAppSettings() async => true;

  @override
  Future<bool> openLocationSettings() async => true;

  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      const Stream<Position>.empty();

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
