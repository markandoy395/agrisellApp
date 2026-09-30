import 'package:agresell_app/features/rider/deliveries/data/rider_live_location_store.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_live_location_policy.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';

class InMemoryRiderLiveLocationStore implements RiderLiveLocationStore {
  InMemoryRiderLiveLocationStore({
    Map<String, Set<String>> participants = const {},
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       _participants = {
         for (final entry in participants.entries)
           entry.key: Set.unmodifiable(entry.value),
       };

  final DateTime Function() _clock;
  final Map<String, Set<String>> _participants;
  final Map<String, RiderLocationUpdate> _latest = {};

  @override
  Future<void> publish({
    required DeliveryRequest request,
    required DeliveryStatus status,
    required RiderLocationUpdate update,
  }) async {
    final riderId = update.riderId;
    if (riderId == null || update.deliveryId != request.id) {
      throw const RiderLiveLocationAccessException(
        'Location identity is missing.',
      );
    }
    final access = RiderLiveLocationAccess.authorize(
      request: request,
      riderId: riderId,
      status: status,
    );
    if (!access.allowed) throw RiderLiveLocationAccessException(access.reason);
    _validateUpdate(update);
    final previous = _latest[request.id];
    if (previous != null && !_isMeaningful(previous, update)) return;
    _latest[request.id] = update;
  }

  @override
  Future<RiderLocationUpdate?> latest({
    required String deliveryId,
    required String participantId,
  }) async {
    final allowed = _participants[deliveryId] ?? const <String>{};
    final update = _latest[deliveryId];
    if (update == null ||
        (participantId != update.riderId && !allowed.contains(participantId))) {
      throw const RiderLiveLocationAccessException(
        'Tracking access is not authorized.',
      );
    }
    return update;
  }

  @override
  Future<void> stop({
    required String deliveryId,
    required String riderId,
  }) async {
    final update = _latest[deliveryId];
    if (update != null && update.riderId != riderId) {
      throw const RiderLiveLocationAccessException(
        'Only the assigned rider can stop this tracking session.',
      );
    }
    _latest.remove(deliveryId);
  }

  void _validateUpdate(RiderLocationUpdate update) {
    final age = _clock().difference(update.capturedAt);
    if (!update.hasValidCoordinates ||
        update.isMocked ||
        !update.accuracyMeters.isFinite ||
        update.accuracyMeters < 0 ||
        update.accuracyMeters > RiderLocationQualityRules.poorMeters ||
        age > RiderLocationQualityRules.maxAge ||
        age < -RiderLocationQualityRules.futureTolerance) {
      throw const RiderLiveLocationAccessException(
        'The location update is invalid or stale.',
      );
    }
  }

  bool _isMeaningful(
    RiderLocationUpdate previous,
    RiderLocationUpdate current,
  ) {
    final elapsed = current.capturedAt.difference(previous.capturedAt);
    final distance = routePointDistanceMeters(
      DeliveryRoutePoint(
        latitude: previous.latitude,
        longitude: previous.longitude,
      ),
      DeliveryRoutePoint(
        latitude: current.latitude,
        longitude: current.longitude,
      ),
    );
    return elapsed >= const Duration(seconds: 10) || distance >= 25;
  }
}
