import 'package:latlong2/latlong.dart';

import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

enum DeliveryGpsState {
  recent,
  stale,
  noLocation,
  unassigned;

  String get label => switch (this) {
    DeliveryGpsState.recent => 'Recent location',
    DeliveryGpsState.stale => 'Stale location',
    DeliveryGpsState.noLocation => 'No location',
    DeliveryGpsState.unassigned => 'Unassigned',
  };

  bool get isLive => this == DeliveryGpsState.recent;
  bool get isStale => this == DeliveryGpsState.stale;
}

class DeliveryTrackingPoint {
  const DeliveryTrackingPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address = '',
    this.contactName,
    this.contactPhone,
  });

  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String? contactName;
  final String? contactPhone;

  LatLng get latLng => LatLng(latitude, longitude);
}

class DeliveryTrackingCheckpoint {
  const DeliveryTrackingCheckpoint({
    required this.id,
    required this.label,
    required this.isCompleted,
    this.isActive = false,
    this.timestamp,
    this.notes,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String label;
  final bool isCompleted;
  final bool isActive;
  final DateTime? timestamp;
  final String? notes;
  final double? latitude;
  final double? longitude;

  LatLng? get latLng =>
      latitude != null && longitude != null ? LatLng(latitude!, longitude!) : null;
}

class DeliveryTrackingSnapshot {
  const DeliveryTrackingSnapshot({
    required this.orderId,
    required this.status,
    required this.gpsState,
    this.deliveryId,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.riderVehicle,
    this.riderLatitude,
    this.riderLongitude,
    this.riderHeading = 0,
    this.speedKph = 0,
    this.locationUpdatedAt,
    this.pickup,
    this.destination,
    this.routeCoordinates = const [],
    this.distanceKm = 0,
    this.estimatedTravelMinutes = 0,
    this.estimatedArrival,
    this.checkpoints = const [],
    this.errorMessage,
  });

  final String orderId;
  final PlacedOrderStatus status;
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
  final DeliveryTrackingPoint? pickup;
  final DeliveryTrackingPoint? destination;
  final List<LatLng> routeCoordinates;
  final double distanceKm;
  final int estimatedTravelMinutes;
  final DateTime? estimatedArrival;
  final List<DeliveryTrackingCheckpoint> checkpoints;
  final String? errorMessage;

  bool get hasRiderCoordinates =>
      riderLatitude != null &&
      riderLongitude != null &&
      riderLatitude!.isFinite &&
      riderLongitude!.isFinite &&
      riderLatitude!.abs() <= 90 &&
      riderLongitude!.abs() <= 180;

  LatLng? get riderLatLng =>
      hasRiderCoordinates ? LatLng(riderLatitude!, riderLongitude!) : null;

  bool get hasRoute => routeCoordinates.length > 1;

  String get arrivalWindowText {
    if (estimatedArrival == null) {
      if (estimatedTravelMinutes > 0) {
        return 'Estimated: ~$estimatedTravelMinutes mins';
      }
      return 'Calculating arrival window…';
    }
    final hour = estimatedArrival!.hour;
    final minute = estimatedArrival!.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return 'Arrival around $standardHour:$minute $period (~$estimatedTravelMinutes mins)';
  }

  String get speedText {
    if (speedKph <= 0.5) return 'Stationary';
    return '${speedKph.toStringAsFixed(0)} km/h';
  }

  String get distanceText {
    if (distanceKm <= 0) return '';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  DeliveryTrackingSnapshot copyWith({
    String? orderId,
    PlacedOrderStatus? status,
    DeliveryGpsState? gpsState,
    String? deliveryId,
    String? riderId,
    String? riderName,
    String? riderPhone,
    String? riderVehicle,
    double? riderLatitude,
    double? riderLongitude,
    double? riderHeading,
    double? speedKph,
    DateTime? locationUpdatedAt,
    DeliveryTrackingPoint? pickup,
    DeliveryTrackingPoint? destination,
    List<LatLng>? routeCoordinates,
    double? distanceKm,
    int? estimatedTravelMinutes,
    DateTime? estimatedArrival,
    List<DeliveryTrackingCheckpoint>? checkpoints,
    String? errorMessage,
  }) => DeliveryTrackingSnapshot(
    orderId: orderId ?? this.orderId,
    status: status ?? this.status,
    gpsState: gpsState ?? this.gpsState,
    deliveryId: deliveryId ?? this.deliveryId,
    riderId: riderId ?? this.riderId,
    riderName: riderName ?? this.riderName,
    riderPhone: riderPhone ?? this.riderPhone,
    riderVehicle: riderVehicle ?? this.riderVehicle,
    riderLatitude: riderLatitude ?? this.riderLatitude,
    riderLongitude: riderLongitude ?? this.riderLongitude,
    riderHeading: riderHeading ?? this.riderHeading,
    speedKph: speedKph ?? this.speedKph,
    locationUpdatedAt: locationUpdatedAt ?? this.locationUpdatedAt,
    pickup: pickup ?? this.pickup,
    destination: destination ?? this.destination,
    routeCoordinates: routeCoordinates ?? this.routeCoordinates,
    distanceKm: distanceKm ?? this.distanceKm,
    estimatedTravelMinutes:
        estimatedTravelMinutes ?? this.estimatedTravelMinutes,
    estimatedArrival: estimatedArrival ?? this.estimatedArrival,
    checkpoints: checkpoints ?? this.checkpoints,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
