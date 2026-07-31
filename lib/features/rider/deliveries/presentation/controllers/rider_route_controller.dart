import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_route_cache.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_routing_service.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_target.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

part 'rider_route_controller_requests.dart';
part 'rider_route_controller_actions.dart';

enum RiderRouteState { idle, loading, ready, stale, error }

class RiderRouteController extends ChangeNotifier {
  RiderRouteController({RiderRoutingService? service, RiderRouteCache? cache})
    : _service = service ?? OsrmRiderRoutingService(),
      _cache = cache ?? RiderRouteCache();

  static const _offRouteThresholdMeters = 100.0;
  static const _requestMovementThresholdMeters = 60.0;
  static const _refreshMovementThresholdMeters = 500.0;
  static const _snapThresholdMeters = 60.0;
  static const _retryInterval = Duration(seconds: 45);
  static const _movingRefreshInterval = Duration(minutes: 2);

  final RiderRoutingService _service;
  final RiderRouteCache _cache;
  RiderRouteState _state = RiderRouteState.idle;
  List<RiderRoutePlan> _routes = const [];
  int _selectedIndex = 0;
  String? _selectedRequestId;
  String? _errorMessage;
  DateTime? _lastAttempt;
  DeliveryRoutePoint? _lastRequestOrigin;
  DeliveryRoutePoint? _lastLocation;
  DateTime? _routeUpdatedAt;
  Future<void>? _requestInFlight;
  _QueuedRouteRequest? _pendingRequest;
  String? _inFlightDestinationKey;
  int _latestGeneration = 0;
  bool _isOnline = true;

  RiderRouteState get state => _state;
  List<RiderRoutePlan> get routes => List.unmodifiable(_routes);
  RiderRoutePlan? get activeRoute =>
      _routes.isEmpty ? null : _routes[_selectedIndex];
  String? get selectedRequestId => _selectedRequestId;
  String? get errorMessage => _errorMessage;
  bool get isUsingCachedRoute => _state == RiderRouteState.stale;
  bool get isOnline => _isOnline;
  bool get canRefresh => _isOnline && _requestInFlight == null;
  DateTime? get routeUpdatedAt => _routeUpdatedAt;

  double get progressFraction {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return 0;
    return routeProgressFraction(location, route.points);
  }

  double get remainingDistanceKm {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return route?.distanceKm ?? 0;
    return remainingRouteDistanceMeters(location, route.points) / 1000;
  }

  int get remainingTravelMinutes {
    final route = activeRoute;
    if (route == null) return 0;
    return (route.estimatedTravelMinutes * (1 - progressFraction)).ceil().clamp(
      0,
      route.estimatedTravelMinutes,
    );
  }

  DateTime? get estimatedArrival => activeRoute == null
      ? null
      : DateTime.now().add(Duration(minutes: remainingTravelMinutes));

  double get offRouteDistanceMeters {
    final route = activeRoute;
    final location = _lastLocation;
    if (route == null || location == null) return 0;
    return distanceFromRouteMeters(location, route.points);
  }

  void setConnectivity(bool isOnline) {
    if (_isOnline == isOnline) return;
    _isOnline = isOnline;
    if (!isOnline) {
      _state = _routes.isEmpty ? RiderRouteState.error : RiderRouteState.stale;
      _errorMessage = 'Offline. The last saved route remains visible.';
    }
    notifyListeners();
  }

  Future<void> restore() async {
    final cached = await _cache.load();
    if (cached == null) return;
    _routes = cached.routes;
    _selectedIndex = cached.selectedIndex;
    _selectedRequestId = activeRoute?.requestId;
    _state = RiderRouteState.stale;
    _routeUpdatedAt = activeRoute?.calculatedAt;
    notifyListeners();
  }

  Future<void> synchronize({
    required RiderDeviceLocation location,
    required List<DeliveryRequest> requests,
    required bool navigationActive,
  }) async {
    final request = selectRiderRouteTarget(requests, _selectedRequestId);
    if (request == null) {
      if (_selectedRequestId != null || _routes.isNotEmpty) clear();
      return;
    }
    if (!navigationActive) return;
    _selectedRequestId = request.id;
    final destination = riderRouteDestination(request);
    if (destination == null) return;
    final origin = DeliveryRoutePoint(
      latitude: location.latitude,
      longitude: location.longitude,
    );
    _lastLocation = origin;
    final destinationKey =
        '${request.id}:${riderRouteUsesDeliveryLocation(request) ? 'delivery' : 'pickup'}';
    final current = activeRoute;
    final destinationChanged = current?.destinationKey != destinationKey;
    if (destinationChanged && current?.requestId != request.id) {
      _routes = const [];
      _selectedIndex = 0;
    }
    if (!_isOnline) {
      _state = _routes.isEmpty ? RiderRouteState.error : RiderRouteState.stale;
      _errorMessage = 'Offline. The last saved route remains visible.';
      notifyListeners();
      return;
    }
    final offRoute =
        current != null &&
        distanceFromRouteMeters(origin, current.points) >
            _offRouteThresholdMeters;
    final movement = _lastRequestOrigin == null
        ? double.infinity
        : routePointDistanceMeters(origin, _lastRequestOrigin!);
    final mayRetry =
        _lastAttempt == null ||
        DateTime.now().difference(_lastAttempt!) >= _retryInterval;
    final routeOld =
        _routeUpdatedAt == null ||
        DateTime.now().difference(_routeUpdatedAt!) >= _movingRefreshInterval;
    final needsInitial =
        current == null &&
        _requestInFlight == null &&
        (_state != RiderRouteState.error || mayRetry);
    final significantProgress =
        movement >= _refreshMovementThresholdMeters && routeOld;
    if (destinationChanged ||
        needsInitial ||
        (offRoute && movement >= _requestMovementThresholdMeters) ||
        significantProgress ||
        (_state == RiderRouteState.stale && mayRetry)) {
      await _requestRoutes(
        requestId: request.id,
        destinationKey: destinationKey,
        origin: origin,
        destination: destination,
      );
      return;
    }
    notifyListeners();
  }

  void _notify() => notifyListeners();
}
