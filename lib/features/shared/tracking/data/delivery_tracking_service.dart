import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/routing/data/osrm_delivery_route_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';
import 'delivery_tracking_checkpoint_builder.dart';
import 'delivery_tracking_fallback_route.dart';
import 'delivery_tracking_remote_loader.dart';

class DeliveryTrackingService {
  DeliveryTrackingService({
    SupabaseClient? client,
    DeliveryRouteService? routingService,
  })  : _client = client,
        _routingService = routingService ?? OsrmDeliveryRouteService();

  final SupabaseClient? _client;
  final DeliveryRouteService _routingService;

  SupabaseClient? get _resolvedClient {
    if (_client != null) return _client;
    return AgrisellSupabase.isInitialized ? AgrisellSupabase.client : null;
  }

  static const int staleGpsThresholdSeconds =
      DeliveryTrackingRemoteLoader.staleGpsThresholdSeconds;

  Future<DeliveryTrackingSnapshot> fetchTracking(PlacedOrder order) async {
    final now = DateTime.now();
    final client = _resolvedClient;

    // 1. Resolve Pickup and Destination coordinates
    final destinationLat = order.deliveryLatitude ?? 8.4772;
    final destinationLng = order.deliveryLongitude ?? 124.6459;
    final destination = DeliveryTrackingPoint(
      name: order.buyerName.isNotEmpty ? order.buyerName : 'Delivery Destination',
      latitude: destinationLat,
      longitude: destinationLng,
      address: order.deliveryAddress.isNotEmpty
          ? order.deliveryAddress.replaceAll('\n', ', ')
          : 'Buyer address',
      contactPhone: order.phoneNumber,
    );

    final pickup = DeliveryTrackingPoint(
      name: order.items.isNotEmpty ? order.items.first.sellerName : 'Farmer Farm',
      latitude: 8.4912,
      longitude: 124.6591,
      address: 'AgriSell Certified Farm',
    );

    // 2. Load live delivery and rider GPS from Supabase or simulated fallback
    final live = await DeliveryTrackingRemoteLoader.load(
      client: client,
      order: order,
      pickup: pickup,
      destination: destination,
      now: now,
    );

    // 3. Compute road route via OSRM or straight-line fallback
    List<LatLng> routePoints = [];
    double distanceKm = 0.0;
    int estimatedMinutes = 0;

    final startPoint = (live.riderLatitude != null && live.riderLongitude != null)
        ? DeliveryRoutePoint(
            latitude: live.riderLatitude!,
            longitude: live.riderLongitude!,
          )
        : DeliveryRoutePoint(
            latitude: pickup.latitude,
            longitude: pickup.longitude,
          );
    final endPoint = DeliveryRoutePoint(
      latitude: destination.latitude,
      longitude: destination.longitude,
    );

    try {
      final activeRoute = await _routingService.findRoute(
        origin: startPoint,
        destination: endPoint,
      );
      if (activeRoute != null && activeRoute.points.length > 1) {
        routePoints = activeRoute.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false);
        distanceKm = activeRoute.distanceKm;
        estimatedMinutes = activeRoute.estimatedTravelMinutes;
      }
    } catch (_) {
      final isShipping = order.status == PlacedOrderStatus.shipping;
      routePoints = DeliveryTrackingFallbackRoute.createPoints(
        start: LatLng(startPoint.latitude, startPoint.longitude),
        end: LatLng(endPoint.latitude, endPoint.longitude),
        pickup: isShipping ? LatLng(pickup.latitude, pickup.longitude) : null,
      );
      distanceKm =
          DeliveryTrackingFallbackRoute.calculateDistanceKm(routePoints);
      estimatedMinutes =
          DeliveryTrackingFallbackRoute.estimateMinutes(distanceKm);
    }

    final estimatedArrival = estimatedMinutes > 0
        ? now.add(Duration(minutes: estimatedMinutes))
        : null;

    // 4. Build checkpoints
    final checkpoints = DeliveryTrackingCheckpointBuilder.build(
      order: order,
      now: now,
      riderLat: live.riderLatitude,
      riderLng: live.riderLongitude,
    );

    return DeliveryTrackingSnapshot(
      orderId: order.id,
      status: order.status,
      gpsState: live.gpsState,
      deliveryId: live.deliveryId,
      riderId: live.riderId,
      riderName: live.riderName,
      riderPhone: live.riderPhone,
      riderVehicle: live.riderVehicle,
      riderLatitude: live.riderLatitude,
      riderLongitude: live.riderLongitude,
      riderHeading: live.riderHeading,
      speedKph: live.speedKph,
      locationUpdatedAt: live.locationUpdatedAt,
      pickup: pickup,
      destination: destination,
      routeCoordinates: routePoints,
      distanceKm: distanceKm,
      estimatedTravelMinutes: estimatedMinutes,
      estimatedArrival: estimatedArrival,
      checkpoints: checkpoints,
    );
  }
}
