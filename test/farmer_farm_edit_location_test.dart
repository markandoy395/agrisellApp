import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';

import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_farm_edit_card.dart';
import 'package:agresell_app/features/farmer/registration/domain/farm_model.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

void main() {
  testWidgets('disabled GPS opens settings and resumes capture on return', (
    tester,
  ) async {
    final gps = _GpsGateway()..enabled = false;
    final service = _FarmService();
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
    await tester.pumpAndSettle();
    expect(gps.locationSettingsCalls, 1);
    expect(gps.currentPositionCalls, 0);
    expect(find.text('Retry GPS capture'), findsOneWidget);
    gps.enabled = true;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(gps.currentPositionCalls, 1);
    expect(find.text('Retry GPS capture'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('denied GPS cannot save old farm coordinates and can retry', (
    tester,
  ) async {
    final gps = _GpsGateway()..permission = LocationPermission.denied;
    final service = _FarmService();
    await tester.binding.setSurfaceSize(const Size(320, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
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
    await tester.pumpAndSettle();
    expect(gps.permissionRequests, 1);
    await tester.ensureVisible(find.text('Save Farm'));
    await tester.tap(find.text('Save Farm'));
    await tester.pumpAndSettle();
    expect(service.savedDraft, isNull);
    expect(gps.currentPositionCalls, 0);
    gps.permission = LocationPermission.whileInUse;
    await tester.ensureVisible(find.text('Retry GPS capture'));
    await tester.tap(find.text('Retry GPS capture'));
    await tester.pumpAndSettle();
    expect(gps.currentPositionCalls, 1);
    await tester.ensureVisible(find.text('Save Farm'));
    await tester.tap(find.text('Save Farm'));
    await tester.pumpAndSettle();
    expect(service.savedDraft?.latitude, 8.6346564);
    expect(service.savedDraft?.longitude, 126.0952993);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening a farm captures GPS and saving uses those coordinates', (
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
    await tester.pumpAndSettle();
    expect(gps.currentPositionCalls, 1);
    expect(service.savedDraft, isNull);
    expect(find.textContaining('location on map'), findsNothing);

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
    province: 'Surigao del Sur',
    cityMunicipality: 'Lianga',
    barangay: 'Poblacion',
    size: 12,
    farmingType: 'Aquaponic farming',
    latitude: 1,
    longitude: 2,
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
  var enabled = true;
  var permission = LocationPermission.whileInUse;
  var locationSettingsCalls = 0;
  var appSettingsCalls = 0;
  var permissionRequests = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

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
  Future<bool> isServiceEnabled() async => enabled;

  @override
  Future<bool> openAppSettings() async {
    appSettingsCalls++;
    return true;
  }

  @override
  Future<bool> openLocationSettings() async {
    locationSettingsCalls++;
    return true;
  }

  @override
  Stream<Position> positionStream({LocationSettings? settings}) =>
      const Stream.empty();

  @override
  Future<LocationPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }
}
