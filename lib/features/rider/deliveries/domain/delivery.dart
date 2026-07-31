import 'delivery_json.dart';
import 'delivery_priority.dart';
import 'delivery_status.dart';

class Delivery {
  const Delivery({
    required this.deliveryId,
    required this.orderId,
    required this.deliveryStatus,
    required this.createdAt,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.vehicleTypes,
    this.coldChainAvailable,
    this.pickupLocation,
    this.dropoffLocation,
    this.distanceKm,
    this._assignedToCurrentRider = false,
  });

  factory Delivery.fromJson(Map<String, Object?> json) => Delivery(
    deliveryId: deliveryString(json['delivery_id']),
    orderId: deliveryString(json['order_id']),
    deliveryStatus: DeliveryStatus.fromBackendValue(
      deliveryString(json['delivery_status'], fallback: 'pending'),
    ),
    estimatedDeliveryTime: deliveryDateTime(json['estimated_delivery_time']),
    actualDeliveryTime: deliveryDateTime(json['actual_delivery_time']),
    createdAt:
        deliveryDateTime(json['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    vehicleTypes: json['vehicle_types'] as String?,
    coldChainAvailable: json['cold_chain_available'] as bool?,
    pickupLocation: json['pickup_location'] as String?,
    dropoffLocation: json['dropoff_location'] as String?,
    distanceKm: deliveryDouble(json['distance_km']),
    assignedToCurrentRider:
        json['assigned_to_current_rider'] as bool? ?? false,
  );

  final String deliveryId;
  final String orderId;
  final DeliveryStatus deliveryStatus;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final DateTime createdAt;
  final String? vehicleTypes;
  final bool? coldChainAvailable;
  final String? pickupLocation;
  final String? dropoffLocation;
  final double? distanceKm;
  final bool _assignedToCurrentRider;

  // Compatibility values for presentation-only request calculations. They are
  // deliberately not serialized because they are absent from the final ERD.
  String? get riderId => _assignedToCurrentRider ? 'current-rider' : null;
  String? get logisticsCompanyId => null;
  DeliveryPriority get priority => DeliveryPriority.standard;
  double get totalWeightKg => 0;
  double? get requiredCapacityKg => null;
  int? get estimatedTravelMinutes => null;
  DateTime get pickupDeadline => createdAt;
  DateTime? get deliveryDeadline => estimatedDeliveryTime;
  DateTime? get estimatedDeliveryAt => estimatedDeliveryTime;
  DateTime? get actualDeliveryAt => actualDeliveryTime;
  DateTime get availableAt => createdAt;
  DateTime? get expiresAt => null;
  DateTime? get acceptedAt => _assignedToCurrentRider ? createdAt : null;
  DateTime? get closedAt => actualDeliveryTime;
  String get serviceArea => '';
  DateTime get updatedAt => actualDeliveryTime ?? createdAt;

  Map<String, Object?> toJson() => {
    'delivery_id': deliveryId,
    'order_id': orderId,
    'delivery_status': deliveryStatus.databaseValue,
    'estimated_delivery_time': estimatedDeliveryTime?.toUtc().toIso8601String(),
    'actual_delivery_time': actualDeliveryTime?.toUtc().toIso8601String(),
    'created_at': createdAt.toUtc().toIso8601String(),
    'vehicle_types': vehicleTypes,
    'cold_chain_available': coldChainAvailable,
    'pickup_location': pickupLocation,
    'dropoff_location': dropoffLocation,
    'distance_km': distanceKm,
  };

  Delivery copyWith({DeliveryStatus? deliveryStatus, String? riderId}) =>
      Delivery(
        deliveryId: deliveryId,
        orderId: orderId,
        deliveryStatus: deliveryStatus ?? this.deliveryStatus,
        estimatedDeliveryTime: estimatedDeliveryTime,
        actualDeliveryTime: actualDeliveryTime,
        createdAt: createdAt,
        vehicleTypes: vehicleTypes,
        coldChainAvailable: coldChainAvailable,
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        distanceKm: distanceKm,
        assignedToCurrentRider: riderId != null || _assignedToCurrentRider,
      );

  @override
  bool operator ==(Object other) =>
      other is Delivery && other.deliveryId == deliveryId;
  @override
  int get hashCode => deliveryId.hashCode;
}
