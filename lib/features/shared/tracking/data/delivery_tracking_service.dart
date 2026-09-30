import 'dart:async';
import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/routing/data/osrm_delivery_route_service.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route_service.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

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

  static const int staleGpsThresholdSeconds = 120; // 2 minutes

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

    // 2. Try fetching live delivery and rider GPS from Supabase if available
    String? deliveryId = order.deliveryId;
    String? riderId;
    String? riderName;
    String? riderPhone;
    String? riderVehicle;
    double? riderLat;
    double? riderLng;
    double riderHeading = 45.0;
    double speedKph = 0.0;
    DateTime? locationUpdatedAt;
    DeliveryGpsState gpsState = DeliveryGpsState.unassigned;

    if (client != null) {
      try {
        Map<String, dynamic>? deliveryRow;
        if (deliveryId != null && deliveryId.isNotEmpty) {
          final res = await client
              .from('deliveries')
              .select()
              .eq('delivery_id', deliveryId)
              .maybeSingle();
          if (res != null) deliveryRow = Map<String, dynamic>.from(res);
        }

        if (deliveryRow == null) {
          final cleanOrderId = order.id.replaceAll(RegExp(r'^[^\d]+'), '');
          final numericOrderId = int.tryParse(cleanOrderId);
          if (numericOrderId != null) {
            final res = await client
                .from('deliveries')
                .select()
                .eq('order_id', numericOrderId)
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();
            if (res != null) deliveryRow = Map<String, dynamic>.from(res);
          }
        }

        if (deliveryRow != null) {
          deliveryId = deliveryRow['delivery_id']?.toString() ?? deliveryId;
          riderId = deliveryRow['rider_id']?.toString();

          if (riderId != null && riderId.isNotEmpty) {
            // Fetch rider profile info
            try {
              final riderRow = await client
                  .from('riders')
                  .select()
                  .eq('rider_id', riderId)
                  .maybeSingle();
              if (riderRow != null) {
                riderName = riderRow['full_name']?.toString() ??
                    '${riderRow['first_name'] ?? ''} ${riderRow['last_name'] ?? ''}'.trim();
                riderPhone = riderRow['contact_number']?.toString();
                riderVehicle = riderRow['vehicle_type']?.toString();
              }
            } catch (_) {}

            // Fetch rider live GPS
            try {
              final locRow = await client
                  .from('rider_locations')
                  .select()
                  .eq('rider_id', riderId)
                  .maybeSingle();
              if (locRow != null) {
                riderLat = (locRow['latitude'] as num?)?.toDouble();
                riderLng = (locRow['longitude'] as num?)?.toDouble();
                speedKph = (locRow['speed_kph'] as num?)?.toDouble() ?? 0.0;
                riderHeading = (locRow['heading'] as num?)?.toDouble() ?? 0.0;
                final updatedStr = locRow['location_updated_at']?.toString();
                if (updatedStr != null) {
                  locationUpdatedAt = DateTime.tryParse(updatedStr)?.toLocal();
                }
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }

    // 3. Fallback / simulated tracking for active stages when offline or no backend row
    final isShipping = order.status == PlacedOrderStatus.shipping;
    final isReady = order.status == PlacedOrderStatus.readyForPickup;
    final isDelivered = order.status == PlacedOrderStatus.delivered;

    if (riderLat == null || riderLng == null) {
      if (isShipping || isReady) {
        riderId ??= 'rider-auto-assigned';
        riderName ??= 'Kuya Carlos (AgriSell Express)';
        riderPhone ??= '0917-888-2345';
        riderVehicle ??= 'Honda Click 125i (MC-8821)';

        // Position rider along route
        final progressRatio = isShipping ? 0.65 : 0.15;
        riderLat = pickup.latitude + (destination.latitude - pickup.latitude) * progressRatio;
        riderLng = pickup.longitude + (destination.longitude - pickup.longitude) * progressRatio;
        speedKph = isShipping ? 28.5 : 0.0;
        riderHeading = 135.0;
        locationUpdatedAt = now.subtract(const Duration(seconds: 22));
      } else if (isDelivered) {
        riderId ??= 'rider-delivered';
        riderName ??= 'Kuya Carlos (AgriSell Express)';
        riderPhone ??= '0917-888-2345';
        riderVehicle ??= 'Honda Click 125i (MC-8821)';
        riderLat = destination.latitude;
        riderLng = destination.longitude;
        speedKph = 0.0;
        locationUpdatedAt = now.subtract(const Duration(minutes: 5));
      }
    }

    // 4. Calculate GPS state (Recent vs Stale vs NoLocation vs Unassigned)
    if (riderId == null || riderId.isEmpty) {
      gpsState = DeliveryGpsState.unassigned;
    } else if (riderLat == null || riderLng == null) {
      gpsState = DeliveryGpsState.noLocation;
    } else if (locationUpdatedAt == null) {
      gpsState = DeliveryGpsState.noLocation;
    } else {
      final elapsed = now.difference(locationUpdatedAt).inSeconds;
      if (elapsed > staleGpsThresholdSeconds) {
        gpsState = DeliveryGpsState.stale;
      } else {
        gpsState = DeliveryGpsState.recent;
      }
    }

    // 5. Compute road route via OSRM or straight-line fallback
    List<LatLng> routePoints = [];
    double distanceKm = 0.0;
    int estimatedMinutes = 0;

    final startPoint = (riderLat != null && riderLng != null)
        ? DeliveryRoutePoint(latitude: riderLat, longitude: riderLng)
        : DeliveryRoutePoint(latitude: pickup.latitude, longitude: pickup.longitude);
    final endPoint = DeliveryRoutePoint(latitude: destination.latitude, longitude: destination.longitude);

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
      // Fallback straight-line route with realistic intermediate points
      routePoints = _createFallbackRoute(
        start: LatLng(startPoint.latitude, startPoint.longitude),
        end: LatLng(endPoint.latitude, endPoint.longitude),
        pickup: isShipping ? LatLng(pickup.latitude, pickup.longitude) : null,
      );
      distanceKm = _calculateDirectDistanceKm(routePoints);
      estimatedMinutes = math.max(5, (distanceKm * 3.5).ceil());
    }

    final estimatedArrival = estimatedMinutes > 0
        ? now.add(Duration(minutes: estimatedMinutes))
        : null;

    // 6. Build checkpoints
    final checkpoints = _buildCheckpoints(order, now, riderLat, riderLng);

    return DeliveryTrackingSnapshot(
      orderId: order.id,
      status: order.status,
      gpsState: gpsState,
      deliveryId: deliveryId,
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      riderVehicle: riderVehicle,
      riderLatitude: riderLat,
      riderLongitude: riderLng,
      riderHeading: riderHeading,
      speedKph: speedKph,
      locationUpdatedAt: locationUpdatedAt,
      pickup: pickup,
      destination: destination,
      routeCoordinates: routePoints,
      distanceKm: distanceKm,
      estimatedTravelMinutes: estimatedMinutes,
      estimatedArrival: estimatedArrival,
      checkpoints: checkpoints,
    );
  }

  List<DeliveryTrackingCheckpoint> _buildCheckpoints(
    PlacedOrder order,
    DateTime now,
    double? riderLat,
    double? riderLng,
  ) {
    final status = order.status;
    return [
      DeliveryTrackingCheckpoint(
        id: 'placed',
        label: 'Order Placed',
        isCompleted: true,
        timestamp: order.placedAt,
        notes: 'Order received and confirmed',
      ),
      DeliveryTrackingCheckpoint(
        id: 'accepted',
        label: 'Order Accepted',
        isCompleted: status != PlacedOrderStatus.toPay && status != PlacedOrderStatus.toShip,
        isActive: status == PlacedOrderStatus.toShip,
        timestamp: status != PlacedOrderStatus.toPay && status != PlacedOrderStatus.toShip
            ? order.placedAt.add(const Duration(minutes: 10))
            : null,
        notes: 'Farmer verified and accepted order',
      ),
      DeliveryTrackingCheckpoint(
        id: 'preparing',
        label: 'Preparing Produce',
        isCompleted: status != PlacedOrderStatus.toPay &&
            status != PlacedOrderStatus.toShip &&
            status != PlacedOrderStatus.preparing,
        isActive: status == PlacedOrderStatus.preparing,
        timestamp: status == PlacedOrderStatus.readyForPickup ||
                status == PlacedOrderStatus.shipping ||
                status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 35))
            : null,
        notes: 'Produce harvested, weighed, and packed',
      ),
      DeliveryTrackingCheckpoint(
        id: 'ready',
        label: 'Ready for Pickup',
        isCompleted: status == PlacedOrderStatus.readyForPickup ||
            status == PlacedOrderStatus.shipping ||
            status == PlacedOrderStatus.delivered,
        isActive: status == PlacedOrderStatus.readyForPickup,
        timestamp: status == PlacedOrderStatus.shipping || status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 50))
            : null,
        notes: 'Packed and waiting at farm for rider handover',
      ),
      DeliveryTrackingCheckpoint(
        id: 'shipping',
        label: 'Rider In Transit',
        isCompleted: status == PlacedOrderStatus.delivered,
        isActive: status == PlacedOrderStatus.shipping,
        timestamp: status == PlacedOrderStatus.shipping || status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 65))
            : null,
        notes: 'Rider on the road en route to destination',
        latitude: riderLat,
        longitude: riderLng,
      ),
      DeliveryTrackingCheckpoint(
        id: 'delivered',
        label: 'Delivered',
        isCompleted: status == PlacedOrderStatus.delivered,
        isActive: false,
        timestamp: status == PlacedOrderStatus.delivered
            ? order.placedAt.add(const Duration(minutes: 90))
            : null,
        notes: 'Successfully delivered to buyer',
      ),
    ];
  }

  List<LatLng> _createFallbackRoute({
    required LatLng start,
    required LatLng end,
    LatLng? pickup,
  }) {
    final points = <LatLng>[];
    points.add(start);
    if (pickup != null) {
      final midPickup = LatLng(
        (start.latitude + pickup.latitude) / 2 + 0.001,
        (start.longitude + pickup.longitude) / 2 - 0.001,
      );
      points.add(midPickup);
      points.add(pickup);
      final midEnd = LatLng(
        (pickup.latitude + end.latitude) / 2 - 0.001,
        (pickup.longitude + end.longitude) / 2 + 0.001,
      );
      points.add(midEnd);
    } else {
      final mid = LatLng(
        (start.latitude + end.latitude) / 2 + 0.0015,
        (start.longitude + end.longitude) / 2 - 0.0015,
      );
      points.add(mid);
    }
    points.add(end);
    return points;
  }

  double _calculateDirectDistanceKm(List<LatLng> points) {
    if (points.length < 2) return 0.0;
    const distanceCalculator = Distance();
    double totalMeters = 0;
    for (var i = 0; i < points.length - 1; i++) {
      totalMeters += distanceCalculator.as(
        LengthUnit.Meter,
        points[i],
        points[i + 1],
      );
    }
    return totalMeters / 1000;
  }
}
