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

    final isShipping = order.status == PlacedOrderStatus.shipping;
    final isReady = order.status == PlacedOrderStatus.readyForPickup;
    final isDelivered = order.status == PlacedOrderStatus.delivered;

    if (riderLat == null || riderLng == null) {
      if (isShipping || isReady) {
        riderId ??= 'rider-auto-assigned';
        riderName ??= 'Kuya Carlos (AgriSell Express)';
        riderPhone ??= '0917-888-2345';
        riderVehicle ??= 'Honda Click 125i (MC-8821)';

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
