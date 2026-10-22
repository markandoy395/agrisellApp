import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_card.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_editor.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_form.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  testWidgets('typing and keyboard resizing retain the shipping form', (
    tester,
  ) async {
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ShippingAddressEditor(onSave: (_) async {})),
      ),
    );
    await tester.pumpAndSettle();
    final form = tester.widget<ShippingAddressForm>(
      find.byType(ShippingAddressForm),
    );
    final province = find.widgetWithText(
      TextField,
      'Province (select or type)',
    );
    await tester.ensureVisible(province);
    await tester.enterText(province, 'Manual province');
    await tester.pumpAndSettle();
    expect(tester.widget(find.byType(ShippingAddressForm)), same(form));
    for (final inset in [100.0, 250.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump();
      expect(tester.widget(find.byType(ShippingAddressForm)), same(form));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('missing shipping address captures GPS when saved', (
    tester,
  ) async {
    BuyerShippingAddress? savedAddress;
    final gps = _FakeGpsGateway();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShippingAddressCard(
            address: '',
            gpsGateway: gps,
            onSave: (address) async => savedAddress = address,
          ),
        ),
      ),
    );

    expect(find.text('No shipping address set'), findsOneWidget);
    await tester.tap(find.text('Set shipping address'));
    await tester.pump();

    expect(
      find.text('Set an exact delivery pin, then complete your address.'),
      findsNothing,
    );
    expect(
      find.text(
        'Complete your address. We will capture your delivery GPS location when you save.',
      ),
      findsOneWidget,
    );
    expect(find.text('House number, street, or sitio/purok'), findsOneWidget);
    expect(find.text('Tap to select the delivery pin'), findsNothing);

    await _enterEditable(tester, 0, 'Purok 5');
    await _enterEditable(tester, 1, 'Agusan del Sur');
    await _enterEditable(tester, 2, 'San Francisco');
    await _enterEditable(tester, 3, 'Hubang');
    await _tapSaveAddress(tester);

    expect(gps.currentPositionCalls, 1);
    expect(
      savedAddress?.address,
      'Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, Philippines',
    );
    expect(savedAddress?.latitude, 8.4822);
    expect(savedAddress?.longitude, 124.6472);
    expect(find.text('Shipping address saved.'), findsWidgets);
  });

  testWidgets('editing a saved address fills its fields and uses changed areas', (
    tester,
  ) async {
    BuyerShippingAddress? savedAddress;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ShippingAddressCard(
            address:
                'House 12, Purok 5, Barangay Hubang, San Francisco, Agusan del Sur, 8501, Philippines',
            gpsGateway: _FakeGpsGateway(),
            onSave: (address) async => savedAddress = address,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Edit address'));
    await tester.pumpAndSettle();
    final form = tester.widget<ShippingAddressForm>(
      find.byType(ShippingAddressForm),
    );
    expect(form.streetController.text, 'House 12, Purok 5');
    expect(form.provinceController.text, 'Agusan del Sur');
    expect(form.cityController.text, 'San Francisco');
    expect(form.barangayController.text, 'Hubang');
    expect(form.postalCodeController.text, '8501');
    await _enterEditable(tester, 1, 'Surigao del Sur');
    await _enterEditable(tester, 2, 'Lianga');
    await _enterEditable(tester, 3, 'Poblacion');
    await _enterEditable(tester, 4, '8307');
    await _tapSaveAddress(tester);
    expect(
      savedAddress?.address,
      'House 12, Purok 5, Barangay Poblacion, Lianga, Surigao del Sur, 8307, Philippines',
    );
  });
}

Future<void> _enterEditable(
  WidgetTester tester,
  int index,
  String value,
) async {
  final field = find.byType(EditableText).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump();
}

Future<void> _tapSaveAddress(WidgetTester tester) async {
  final saveButton = find.widgetWithText(FilledButton, 'Save address');
  await tester.scrollUntilVisible(
    saveButton,
    160,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.pumpAndSettle();
  await tester.tap(saveButton);
  await tester.pumpAndSettle();
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
