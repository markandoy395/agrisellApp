import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

/// Resolved live tracking state for a delivery.
class LiveTrackingData {
  const LiveTrackingData({
    required this.gpsState,
    this.deliveryId,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.riderVehicle,
    this.riderLatitude,
    this.riderLongitude,
    this.riderHeading = 45.0,
    this.speedKph = 0.0,
    this.locationUpdatedAt,
  });

  final DeliveryGpsState gpsState;
  final String? deliveryId;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final String? riderVehicle;
  final double? riderLatitude;
  final double? riderLongitude;
  final double riderHeading;
  final double speedKph;
  final DateTime? locationUpdatedAt;
}

/// Helper that queries Supabase for live delivery and rider GPS or provides simulated fallback.
abstract final class DeliveryTrackingRemoteLoader {
  static const int staleGpsThresholdSeconds = 120; // 2 minutes

  static Future<LiveTrackingData> load({
    required SupabaseClient? client,
    required PlacedOrder order,
    required DeliveryTrackingPoint pickup,
    required DeliveryTrackingPoint destination,
    required DateTime now,
  }) async {
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

    if (client != null && client.auth.currentUser != null) {
      try {
        final numericOrderId = int.tryParse(
          order.id.replaceAll(RegExp(r'^[^\d]+'), ''),
        );
        final value = await client.rpc<Object?>(
          'current_delivery_tracking',
          params: {
            'p_delivery_id': int.tryParse(deliveryId ?? ''),
            'p_order_id': numericOrderId,
          },
        );
        if (value is Map) {
          deliveryId = value['delivery_id']?.toString();
          riderId = value['rider_id']?.toString();
          riderName = value['rider_name']?.toString();
          riderPhone = value['rider_phone']?.toString();
          riderVehicle = value['rider_vehicle']?.toString();
          riderLat = (value['latitude'] as num?)?.toDouble();
          riderLng = (value['longitude'] as num?)?.toDouble();
          speedKph = (value['speed_kph'] as num?)?.toDouble() ?? 0;
          riderHeading = (value['heading'] as num?)?.toDouble() ?? 0;
          locationUpdatedAt = DateTime.tryParse(
            value['location_updated_at']?.toString() ?? '',
          )?.toLocal();
        }
      } on Object {
        // Authorization failures never trigger a broader direct-table query.
      }
    }
    final isShipping = order.status == PlacedOrderStatus.shipping;
    final isReady = order.status == PlacedOrderStatus.readyForPickup;
    final isDelivered = order.status == PlacedOrderStatus.delivered;

    if (client == null && (riderLat == null || riderLng == null)) {
      if (isShipping || isReady) {
        riderId ??= 'rider-auto-assigned';
        riderName ??= 'Kuya Carlos (AgriSell Express)';
        riderPhone ??= '0917-888-2345';
        riderVehicle ??= 'Honda Click 125i (MC-8821)';

        final progressRatio = isShipping ? 0.65 : 0.15;
        riderLat =
            pickup.latitude +
            (destination.latitude - pickup.latitude) * progressRatio;
        riderLng =
            pickup.longitude +
            (destination.longitude - pickup.longitude) * progressRatio;
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

    final DeliveryGpsState gpsState;
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

    return LiveTrackingData(
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
      gpsState: gpsState,
    );
  }
}
