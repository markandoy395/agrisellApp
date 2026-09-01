part of 'rider_map_screen.dart';

const _minimumRoadAccessGuideMeters = 4.0;
const _maximumRoadAccessGuideMeters = 1000.0;
const _roadAccessReuseMovementMeters = 50.0;
const _roadAccessConcurrency = 4;

extension _RiderMapRoadAccess on _RiderMapScreenState {
  void _scheduleRoadAccessSync() {
    if (!widget.isActive) return;
    _roadAccessDebounce?.cancel();
    _roadAccessDebounce = Timer(
      const Duration(milliseconds: 900),
      () => unawaited(_refreshRoadAccessConnections()),
    );
  }

  Future<void> _refreshRoadAccessConnections() async {
    final sources = _roadAccessSources();
    if (sources.isEmpty) return;
    final activeRoute = _routeController.activeRoute;
    final fingerprint = [
      for (final source in sources)
        '${source.id}:${source.point.latitude.toStringAsFixed(3)}:'
            '${source.point.longitude.toStringAsFixed(3)}',
      if (activeRoute != null)
        '${activeRoute.id}:${activeRoute.calculatedAt.millisecondsSinceEpoch}',
    ].join('|');
    final now = DateTime.now();
    if (_lastRoadAccessFingerprint == fingerprint &&
        _lastRoadAccessAttempt != null &&
        now.difference(_lastRoadAccessAttempt!) < const Duration(minutes: 2)) {
      return;
    }
    _lastRoadAccessFingerprint = fingerprint;
    _lastRoadAccessAttempt = now;

    final generation = ++_roadAccessGeneration;
    final previous = {for (final item in _roadAccessConnections) item.id: item};
    final next = <String, RiderRoadAccessConnection>{};
    final unresolved = <RiderRoadAccessSource>[];

    for (final source in sources) {
      final routeSnap = _activeRouteSnap(source, activeRoute);
      if (routeSnap != null) {
        final connection = _connectionFromSnap(source, routeSnap);
        if (connection != null) next[source.id] = connection;
        continue;
      }
      final cached = previous[source.id];
      if (cached != null &&
          routePointDistanceMeters(source.point, cached.sourcePoint) <=
              _roadAccessReuseMovementMeters) {
        final distance = routePointDistanceMeters(
          source.point,
          cached.roadPoint,
        );
        if (_isUsefulGuideDistance(distance)) {
          next[source.id] = RiderRoadAccessConnection(
            id: source.id,
            kind: source.kind,
            sourcePoint: source.point,
            roadPoint: cached.roadPoint,
            sourceLabel: source.label,
            roadName: cached.roadName,
            distanceMeters: distance,
          );
        }
        continue;
      }
      unresolved.add(source);
    }

    for (
      var offset = 0;
      offset < unresolved.length;
      offset += _roadAccessConcurrency
    ) {
      final end = (offset + _roadAccessConcurrency)
          .clamp(0, unresolved.length)
          .toInt();
      final batch = unresolved.sublist(offset, end);
      final resolved = await Future.wait([
        for (final source in batch) _resolveRoadAccess(source),
      ]);
      if (!mounted || generation != _roadAccessGeneration) return;
      for (final connection in resolved) {
        if (connection != null) next[connection.id] = connection;
      }
    }

    if (!mounted || generation != _roadAccessGeneration) return;
    _replaceRoadAccessConnections(next.values.toList(growable: false));
  }

  List<RiderRoadAccessSource> _roadAccessSources() {
    final selected = _selectedRoadAccessSource;
    return selected == null ? const [] : [selected];
  }

  RiderRoadAccessSource? _roadAccessSourceForRequest(
    DeliveryRequest request,
    RiderMapMarkerKind markerKind,
  ) {
    final isBuyerDestination =
        markerKind == RiderMapMarkerKind.assignedDelivery &&
        request.stage.isDeliveryLeg;
    final destination = isBuyerDestination
        ? request.deliveryLocation
        : request.pickupLocation;
    if (!destination.hasCoordinates ||
        !RiderMapCameraPolicy.isCoordinateValid(
          destination.latitude!,
          destination.longitude!,
        )) {
      return null;
    }
    return RiderRoadAccessSource(
      id: '${isBuyerDestination ? 'buyer' : 'delivery'}:${request.id}',
      kind: isBuyerDestination
          ? RiderRoadAccessKind.buyer
          : RiderRoadAccessKind.delivery,
      point: DeliveryRoutePoint(
        latitude: destination.latitude!,
        longitude: destination.longitude!,
      ),
      label: isBuyerDestination
          ? 'Assigned delivery destination'
          : request.pickupLocation.address,
      routeRequestId: request.id,
    );
  }

  RiderRoadAccessSource? _roadAccessSourceForFarm(RiderNearbyFarm farm) {
    if (!RiderMapCameraPolicy.isCoordinateValid(
      farm.latitude,
      farm.longitude,
    )) {
      return null;
    }
    return RiderRoadAccessSource(
      id: 'farm:${farm.id}',
      kind: RiderRoadAccessKind.farmer,
      point: DeliveryRoutePoint(
        latitude: farm.latitude,
        longitude: farm.longitude,
      ),
      label: farm.name,
      routeRequestId: 'farm:${farm.id}',
    );
  }

  RiderRoadAccessSnap? _activeRouteSnap(
    RiderRoadAccessSource source,
    RiderRoutePlan? route,
  ) {
    if (route == null) return null;
    if (source.kind == RiderRoadAccessKind.rider) {
      return RiderRoadAccessSnap(
        point: route.snappedOrigin,
        roadName: route.originRoadName,
        distanceMeters: routePointDistanceMeters(
          source.point,
          route.snappedOrigin,
        ),
      );
    }
    if (source.routeRequestId != route.requestId) return null;
    return RiderRoadAccessSnap(
      point: route.snappedDestination,
      roadName: route.destinationRoadName,
      distanceMeters: routePointDistanceMeters(
        source.point,
        route.snappedDestination,
      ),
    );
  }

  Future<RiderRoadAccessConnection?> _resolveRoadAccess(
    RiderRoadAccessSource source,
  ) async {
    final snap = await _roadAccessService.findNearestRoadAccess(source.point);
    return snap == null ? null : _connectionFromSnap(source, snap);
  }

  RiderRoadAccessConnection? _connectionFromSnap(
    RiderRoadAccessSource source,
    RiderRoadAccessSnap snap,
  ) {
    final distance = snap.distanceMeters.isFinite
        ? snap.distanceMeters
        : routePointDistanceMeters(source.point, snap.point);
    if (!_isUsefulGuideDistance(distance) ||
        !RiderMapCameraPolicy.isCoordinateValid(
          snap.point.latitude,
          snap.point.longitude,
        )) {
      return null;
    }
    return RiderRoadAccessConnection(
      id: source.id,
      kind: source.kind,
      sourcePoint: source.point,
      roadPoint: snap.point,
      sourceLabel: source.label,
      roadName: snap.roadName,
      distanceMeters: distance,
    );
  }

  bool _isUsefulGuideDistance(double distance) =>
      distance.isFinite &&
      distance >= _minimumRoadAccessGuideMeters &&
      distance <= _maximumRoadAccessGuideMeters;
}
