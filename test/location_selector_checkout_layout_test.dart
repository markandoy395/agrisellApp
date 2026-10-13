import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_repository.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';
import 'package:agresell_app/features/shared/location/presentation/location_selector.dart';
import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_selector_layout.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_selector_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'modal avoids keyboard and confirms the point shown after switching modes',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({});
      final repository = ConfirmedLocationRepository();
      await repository.confirm(
        LocationOwnerRole.buyer,
        ConfirmedLocation(
          latitude: 8.6346,
          longitude: 126.0953,
          accuracyMeters: 14,
          capturedAt: DateTime.now(),
          address: 'Zamora, Poblacion, Lianga',
        ),
      );
      final gps = _IdleGps();
      addTearDown(gps.dispose);
      ConfirmedLocation? confirmed;
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  confirmed = await showLocationSelector(
                    context,
                    role: LocationOwnerRole.buyer,
                    repository: repository,
                    gpsController: gps,
                  );
                },
                child: const Text('Open picker'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open picker'));
      await tester.pumpAndSettle();
      var picker = tester.widget<LocationSelectorMap>(
        find.byType(LocationSelectorMap),
      );
      const destination = LatLng(8.635, 126.096);
      picker.onSelected(destination);
      await tester.pump();
      final layout = tester.widget<LocationSelectorLayout>(
        find.byType(LocationSelectorLayout),
      );
      layout.onModeChanged(false);
      await tester.pump();
      picker = tester.widget<LocationSelectorMap>(
        find.byType(LocationSelectorMap),
      );
      expect(picker.centerPinMode, isFalse);
      picker.onSelected(const LatLng(8.636, 126.097));
      await tester.pump();
      tester
          .widget<LocationSelectorLayout>(find.byType(LocationSelectorLayout))
          .onModeChanged(true);
      await tester.pump();
      picker = tester.widget<LocationSelectorMap>(
        find.byType(LocationSelectorMap),
      );
      expect(
        picker.controller.camera.center.latitude,
        closeTo(picker.selected.latitude, 0.000001),
      );
      expect(
        picker.controller.camera.center.longitude,
        closeTo(picker.selected.longitude, 0.000001),
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Confirm Location');
      expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(380));
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(confirmed?.latitude, 8.636);
      expect(confirmed?.longitude, 126.097);
      expect(tester.takeException(), isNull);
    },
  );

  for (final keyboardHeight in [0.0, 260.0]) {
    testWidgets('location form fits with keyboard height $keyboardHeight', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 640));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final gps = GpsSelectionController();
      final map = MapController();
      final address = TextEditingController(
        text: 'Zamora, Barangay Poblacion, Lianga, Surigao del Sur',
      );
      final notes = TextEditingController();
      var confirmed = false;
      addTearDown(() {
        gps.dispose();
        map.dispose();
        address.dispose();
        notes.dispose();
      });
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            resizeToAvoidBottomInset: false,
            body: MediaQuery(
              data: MediaQueryData(
                size: const Size(320, 640),
                textScaler: const TextScaler.linear(1.5),
                viewInsets: EdgeInsets.only(bottom: keyboardHeight),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardHeight),
                child: LocationSelectorLayout(
                  centerPinMode: false,
                  onModeChanged: (_) {},
                  onClose: () {},
                  gpsController: gps,
                  offlineTiles: false,
                  mapController: map,
                  selected: const LatLng(8.63, 126.10),
                  detected: const LatLng(8.6346, 126.0953),
                  accuracyMeters: 14,
                  onSelected: (_) {},
                  onMapMoved: (_) {},
                  onTileError: () {},
                  onZoom: (_) {},
                  onUseCurrentLocation: () {},
                  mapKey: GlobalKey(),
                  addressController: address,
                  notesController: notes,
                  canConfirm: true,
                  saving: false,
                  onConfirm: () => confirmed = true,
                  requiresWrittenAddress: true,
                  showAddressFields: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final confirm = find.widgetWithText(FilledButton, 'Confirm Location');
      expect(
        tester.getBottomRight(confirm).dy,
        lessThanOrEqualTo(640 - keyboardHeight),
      );
      await tester.tap(confirm);
      expect(confirmed, isTrue);
      expect(
        find.textContaining('The red pin is your selected destination'),
        findsOneWidget,
      );
      final field = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller == address,
      );
      await tester.ensureVisible(field);
      await tester.pump();
      final input = tester.widget<TextField>(field);
      expect(input.maxLines, 3);
      expect(input.decoration?.helperMaxLines, 3);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'dragged pin is anchored above its coordinate and follows drag delta',
    (tester) async {
      final map = MapController();
      addTearDown(map.dispose);
      const point = LatLng(8.6346, 126.0953);
      LatLng? moved;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationSelectorMap(
              controller: map,
              selected: point,
              detected: point,
              accuracyMeters: 14,
              centerPinMode: false,
              onSelected: (value) => moved = value,
              onMapMoved: (_) {},
              onTileError: () {},
              onZoom: (_) {},
              onUseCurrentLocation: () {},
              locating: false,
              mapKey: GlobalKey(),
            ),
          ),
        ),
      );
      await tester.pump();
      final pin = find.bySemanticsLabel('Draggable selected location pin');
      final anchor = map.camera.latLngToScreenOffset(point);
      final mapOrigin = tester.getTopLeft(find.byType(LocationSelectorMap));
      expect(
        (tester.getBottomLeft(pin) + const Offset(24, 0) - mapOrigin - anchor)
            .distance,
        lessThan(0.01),
      );
      final gesture = tester.widget<GestureDetector>(
        find.ancestor(of: pin, matching: find.byType(GestureDetector)).first,
      );
      const delta = Offset(20, -10);
      gesture.onPanUpdate!(
        DragUpdateDetails(delta: delta, globalPosition: const Offset(999, 999)),
      );
      final expected = map.camera.screenOffsetToLatLng(anchor + delta);
      expect(moved?.latitude, closeTo(expected.latitude, 0.000001));
      expect(moved?.longitude, closeTo(expected.longitude, 0.000001));
      expect(tester.takeException(), isNull);
    },
  );
}

class _IdleGps extends GpsSelectionController {
  @override
  Future<void> start() async {}
}
