import 'package:agresell_app/features/shared/location/presentation/controllers/gps_selection_controller.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_selector_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  testWidgets(
    'simplified farm map hides address inputs and shows map controls',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(326, 640);
      final gps = GpsSelectionController();
      final map = MapController();
      final address = TextEditingController();
      final notes = TextEditingController();
      addTearDown(() {
        gps.dispose();
        map.dispose();
        address.dispose();
        notes.dispose();
        tester.view.resetDevicePixelRatio();
        tester.view.resetPhysicalSize();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocationSelectorLayout(
              centerPinMode: true,
              onModeChanged: (_) {},
              onClose: () {},
              gpsController: gps,
              offlineTiles: false,
              mapController: map,
              selected: const LatLng(14.5995, 120.9842),
              detected: null,
              accuracyMeters: null,
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
              onConfirm: () {},
              requiresWrittenAddress: false,
              showAddressFields: false,
            ),
          ),
        ),
      );

      expect(find.text('Written address'), findsNothing);
      expect(find.text('Landmark or notes'), findsNothing);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.text('Confirm Location'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
