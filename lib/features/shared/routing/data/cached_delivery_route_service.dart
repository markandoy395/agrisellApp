import 'dart:collection';
import 'package:latlong2/latlong.dart';
import '../domain/delivery_route.dart';
import '../domain/delivery_route_service.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';

/// A bounded, short-lived per-service route cache. Never persists GPS positions.
class CachedDeliveryRouteService implements DeliveryRouteService {
  CachedDeliveryRouteService(
    this.delegate, {
    this.ttl = const Duration(minutes: 2),
    this.maximumEntries = 16,
    this.originToleranceMeters = 50,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final DeliveryRouteService delegate;
  final Duration ttl;
  final int maximumEntries;
  final double originToleranceMeters;
  final DateTime Function() _now;
  final _entries = Queue<_RouteEntry>();
  final _requests = AsyncOperationGate();
  final _distance = const Distance();

  @override
  Future<DeliveryRouteInfo?> findRoute({
    required DeliveryRoutePoint origin,
    required DeliveryRoutePoint destination,
  }) {
    _entries.removeWhere((entry) => _now().difference(entry.createdAt) >= ttl);
    for (final entry in _entries.toList().reversed) {
      if (entry.destination.latitude == destination.latitude &&
          entry.destination.longitude == destination.longitude &&
          _distance(
                LatLng(origin.latitude, origin.longitude),
                LatLng(entry.origin.latitude, entry.origin.longitude),
              ) <=
              originToleranceMeters) {
        return Future.value(entry.route);
      }
    }
    final key = (
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    return _requests.run(key, () async {
      final route = await delegate.findRoute(
        origin: origin,
        destination: destination,
      );
      if (route != null && maximumEntries > 0) {
        _entries.add(_RouteEntry(origin, destination, route, _now()));
        while (_entries.length > maximumEntries) {
          _entries.removeFirst();
        }
      }
      return route;
    });
  }
}

class _RouteEntry {
  const _RouteEntry(this.origin, this.destination, this.route, this.createdAt);
  final DeliveryRoutePoint origin;
  final DeliveryRoutePoint destination;
  final DeliveryRouteInfo route;
  final DateTime createdAt;
}
