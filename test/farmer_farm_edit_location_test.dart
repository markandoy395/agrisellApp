import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_card.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

void main() {
  testWidgets('saving a farm automatically captures current GPS coordinates', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    final service = _FarmService();
    final gps = _GpsGateway();
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: FarmerFarmEditCard(
              service: service,
              gpsGateway: gps,
              onCancel: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final save = find.text('Save Farm');
    await tester.scrollUntilVisible(
      save,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(save);
    await tester.pumpAndSettle();

    expect(gps.currentPositionCalls, 1);
    expect(service.savedDraft?.latitude, 8.6346564);
    expect(service.savedDraft?.longitude, 126.0952993);
  });
}

class _FarmService extends FarmerFarmService {
  FarmEditDraft? savedDraft;

  @override
  Future<FarmModel?> load() async => const FarmModel(
    id: 4,
    farmerId: 6,
    name: 'Test Farm',
    mainCrops: ['Corn'],
    location: 'Test farm address',
  );

  @override
  Future<FarmModel> save(FarmEditDraft draft, {int? farmId}) async {
    savedDraft = draft;
    return FarmModel(
      id: farmId ?? 4,
      farmerId: 6,
      name: draft.name,
      mainCrops: draft.mainCrops,
      location: draft.location,
      latitude: draft.latitude,
      longitude: draft.longitude,
    );
  }
}

class _GpsGateway implements GpsLocationGateway {
  var currentPositionCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Future<Position> currentPosition({required LocationSettings settings}) async {
    currentPositionCalls++;
    return Position(
      longitude: 126.0952993,
      latitude: 8.6346564,
      timestamp: DateTime.now(),
      accuracy: 5,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
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
      const Stream.empty();

  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.whileInUse;
}
