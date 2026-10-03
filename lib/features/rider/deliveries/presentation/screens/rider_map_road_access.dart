part of 'rider_map_screen.dart';

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
      final routeSnap = RiderMapRoadAccessResolver.activeRouteSnap(
        source,
        activeRoute,
      );
      if (routeSnap != null) {
        final connection = RiderMapRoadAccessResolver.connectionFromSnap(
          source,
          routeSnap,
        );
        if (connection != null) next[source.id] = connection;
        continue;
      }
      final cached = previous[source.id];
      if (cached != null &&
          routePointDistanceMeters(source.point, cached.sourcePoint) <=
              RiderMapRoadAccessResolver.roadAccessReuseMovementMeters) {
        final distance = routePointDistanceMeters(
          source.point,
          cached.roadPoint,
        );
        if (RiderMapRoadAccessResolver.isUsefulGuideDistance(distance)) {
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
      offset += RiderMapRoadAccessResolver.roadAccessConcurrency
    ) {
      final end = (offset + RiderMapRoadAccessResolver.roadAccessConcurrency)
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
  ) =>
      RiderMapRoadAccessResolver.sourceForRequest(request, markerKind);

  RiderRoadAccessSource? _roadAccessSourceForFarm(RiderNearbyFarm farm) =>
      RiderMapRoadAccessResolver.sourceForFarm(farm);

  Future<RiderRoadAccessConnection?> _resolveRoadAccess(
    RiderRoadAccessSource source,
  ) async {
    final snap = await _roadAccessService.findNearestRoadAccess(source.point);
    return snap == null
        ? null
        : RiderMapRoadAccessResolver.connectionFromSnap(source, snap);
  }
}
