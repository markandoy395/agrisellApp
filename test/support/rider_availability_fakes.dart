import 'dart:async';

import 'package:agresell_app/features/rider/dashboard/data/rider_connectivity_service.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

class FakeRiderAvailabilityRepository implements RiderAvailabilityRepository {
  FakeRiderAvailabilityRepository({
    this.serverStatus = RiderAvailability.offline,
  });

  RiderAvailability serverStatus;
  int loadCalls = 0;
  int saveCalls = 0;
  bool failLoad = false;
  bool failSave = false;
  Completer<void>? saveGate;

  @override
  Future<RiderAvailability> loadAvailability(String riderId) async {
    loadCalls++;
    if (failLoad) throw StateError('backend failure');
    return serverStatus;
  }

  @override
  Future<void> saveAvailability(
    String riderId,
    RiderAvailability availability,
  ) async {
    saveCalls++;
    await saveGate?.future;
    if (failSave) throw StateError('backend failure');
    serverStatus = availability;
  }
}

class FakeRiderConnectivityService implements RiderConnectivityService {
  FakeRiderConnectivityService({
    bool isOnline = true,
    RiderInternetStatus? status,
  }) : status =
           status ??
           (isOnline
               ? RiderInternetStatus.online
               : RiderInternetStatus.offline);

  RiderInternetStatus status;
  int checkCalls = 0;
  final StreamController<RiderInternetStatus> _changes =
      StreamController<RiderInternetStatus>.broadcast();

  @override
  Stream<RiderInternetStatus> get connectivityChanges => _changes.stream;

  @override
  Future<RiderInternetStatus> checkConnectivity() async {
    checkCalls++;
    return status;
  }

  void emit(bool value) {
    emitStatus(
      value ? RiderInternetStatus.online : RiderInternetStatus.offline,
    );
  }

  void emitStatus(RiderInternetStatus value) {
    status = value;
    _changes.add(value);
  }

  @override
  void dispose() => _changes.close();
}

class FakeRiderLocationController extends RiderLocationController {
  FakeRiderLocationController({
    this.fakeState = RiderLocationState.ready,
    double accuracyMeters = 5,
  }) : fakeLocation = RiderDeviceLocation(
         latitude: 8.48,
         longitude: 124.65,
         accuracyMeters: accuracyMeters,
         timestamp: DateTime.now(),
       );

  RiderLocationState fakeState;
  RiderDeviceLocation? fakeLocation;
  int refreshCalls = 0;
  int permissionRequestCalls = 0;

  @override
  RiderLocationState get state => fakeState;

  @override
  RiderDeviceLocation? get location => fakeLocation;

  @override
  Future<void> refresh({bool requestPermission = false}) async {
    refreshCalls++;
    if (requestPermission) permissionRequestCalls++;
    notifyListeners();
  }
}
