import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_connectivity_service.dart';
import 'package:agresell_app/features/rider/dashboard/data/temporary_local_rider_availability_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_availability_repository.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_foundation_repositories.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

part 'rider_availability_controller_sync.dart';
part 'rider_availability_controller_toggle.dart';

class RiderAvailabilityController extends ChangeNotifier {
  RiderAvailabilityController({
    required this.deliveryController,
    required this.locationController,
    RiderAvailabilityRepository? repository,
    RiderConnectivityService? connectivityService,
    this.poorAccuracyThresholdMeters = 50,
    this.reconnectCheckInterval = const Duration(seconds: 15),
  }) : _repository =
           repository ??
           (AgrisellSupabase.isInitialized
               ? SupabaseRiderAvailabilityRepository()
               : TemporaryLocalRiderAvailabilityRepository()),
       _connectivity =
           connectivityService ?? createDefaultRiderConnectivityService(),
       _ownsConnectivity = connectivityService == null {
    _lastObservedAvailability = deliveryController.status.availability;
    deliveryController.addListener(_onDeliveryStatusChanged);
  }

  final RiderDeliveryController deliveryController;
  final RiderLocationController locationController;
  final RiderAvailabilityRepository _repository;
  final RiderConnectivityService _connectivity;
  final bool _ownsConnectivity;
  final double poorAccuracyThresholdMeters;
  final Duration reconnectCheckInterval;
  RiderAvailabilitySyncState _syncState = RiderAvailabilitySyncState.idle;
  RiderInternetStatus _internetStatus = RiderInternetStatus.unknown;
  RiderAvailabilityWarning? _warning;
  RiderAvailability? _lastObservedAvailability;
  String? _riderId;
  Future<RiderAvailabilityUpdateResult>? _toggleRequest;
  Future<void>? _initialization;
  Future<void>? _workStatusSync;
  Future<void>? _restoreRequest;
  Future<RiderInternetStatus>? _connectivityCheck;
  RiderAvailability? _pendingWorkStatus;
  StreamSubscription<RiderInternetStatus>? _connectivitySubscription;
  Timer? _reconnectTimer;
  bool _isDisposed = false;
  RiderAvailabilitySyncState get syncState => _syncState;
  RiderInternetStatus get internetStatus => _internetStatus;
  RiderAvailabilityWarning? get warning => _warning;
  RiderAvailability get availability => deliveryController.status.availability;
  RiderAvailability get displayedAvailability => availability;
  bool get isUpdating =>
      _syncState == RiderAvailabilitySyncState.updating ||
      _syncState == RiderAvailabilitySyncState.checkingRequirements;
  bool get isSynchronizing =>
      _syncState == RiderAvailabilitySyncState.synchronizing;
  bool get isBusy => isUpdating || isSynchronizing;
  bool get usesTemporaryData =>
      riderDataOriginOf(_repository) == RiderDataOrigin.temporaryLocal ||
      riderDataOriginOf(_connectivity) == RiderDataOrigin.temporaryLocal;
  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> initialize({required String riderId}) {
    _riderId = riderId;
    return _initialization ??= _initialize().whenComplete(
      () => _initialization = null,
    );
  }

  Future<void> _initialize() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.connectivityChanges.listen(
      _onConnectivityChanged,
    );
    // Connectivity and work status are enough to load dashboard data and
    // preview requests. Location is requested by actions that actually need
    // it (for example going online, accepting, or opening the map).
    await refreshEnvironment();
  }

  Future<void> refreshEnvironment({bool refreshLocation = false}) async {
    final wasOffline = _internetStatus == RiderInternetStatus.offline;
    _internetStatus = RiderInternetStatus.checking;
    _notify();
    final status = await _checkConnectivity();
    if (_isDisposed) return;
    _setInternetStatus(status);
    final restore =
        status == RiderInternetStatus.online && (wasOffline || _riderId != null)
        ? _restoreAuthoritativeStatus()
        : Future<void>.value();
    await Future.wait([
      restore,
      if (refreshLocation) locationController.refresh(),
    ]);
    _notify();
  }

  Future<RiderAvailabilityUpdateResult> setOnline(bool value) {
    final existing = _toggleRequest;
    if (existing != null) return existing;
    if (value == availability.isOnline) {
      return Future.value(const RiderAvailabilityUpdateResult.success());
    }
    final request = _setOnline(value);
    _toggleRequest = request;
    return request.whenComplete(() {
      if (identical(_toggleRequest, request)) _toggleRequest = null;
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    deliveryController.removeListener(_onDeliveryStatusChanged);
    _reconnectTimer?.cancel();
    unawaited(_connectivitySubscription?.cancel());
    if (_ownsConnectivity) _connectivity.dispose();
    super.dispose();
  }
}
