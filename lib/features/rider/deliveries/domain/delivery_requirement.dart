import 'delivery_json.dart';

class DeliveryRequirement {
  const DeliveryRequirement({
    required this.requirementId,
    required this.deliveryId,
    required this.requiresCooling,
    required this.requiresFragileHandling,
    required this.requiresWaterproofCover,
    required this.requiresSpecialHandling,
    required this.createdAt,
    required this.updatedAt,
    this.requiredVehicleType,
    this.minimumCapacityKg,
    this.packageLengthCm,
    this.packageWidthCm,
    this.packageHeightCm,
    this.handlingNotes,
    this.cancellationConditions,
  });

  factory DeliveryRequirement.fromJson(Map<String, Object?> json) =>
      DeliveryRequirement(
        requirementId: deliveryString(json['requirement_id']),
        deliveryId: deliveryString(json['delivery_id']),
        requiredVehicleType: json['required_vehicle_type'] as String?,
        minimumCapacityKg: deliveryDouble(json['minimum_capacity_kg']),
        packageLengthCm: deliveryDouble(json['package_length_cm']),
        packageWidthCm: deliveryDouble(json['package_width_cm']),
        packageHeightCm: deliveryDouble(json['package_height_cm']),
        requiresCooling: json['requires_cooling'] as bool? ?? false,
        requiresFragileHandling:
            json['requires_fragile_handling'] as bool? ?? false,
        requiresWaterproofCover:
            json['requires_waterproof_cover'] as bool? ?? false,
        requiresSpecialHandling:
            json['requires_special_handling'] as bool? ?? false,
        handlingNotes: json['handling_notes'] as String?,
        cancellationConditions: json['cancellation_conditions'] as String?,
        createdAt:
            deliveryDateTime(json['created_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        updatedAt:
            deliveryDateTime(json['updated_at']) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  final String requirementId;
  final String deliveryId;
  final String? requiredVehicleType;
  final double? minimumCapacityKg;
  final double? packageLengthCm;
  final double? packageWidthCm;
  final double? packageHeightCm;
  final bool requiresCooling;
  final bool requiresFragileHandling;
  final bool requiresWaterproofCover;
  final bool requiresSpecialHandling;
  final String? handlingNotes;
  final String? cancellationConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, Object?> toJson() => {
    if (requirementId.isNotEmpty) 'requirement_id': requirementId,
    'delivery_id': deliveryId,
    'required_vehicle_type': requiredVehicleType,
    'minimum_capacity_kg': minimumCapacityKg,
    'package_length_cm': packageLengthCm,
    'package_width_cm': packageWidthCm,
    'package_height_cm': packageHeightCm,
    'requires_cooling': requiresCooling,
    'requires_fragile_handling': requiresFragileHandling,
    'requires_waterproof_cover': requiresWaterproofCover,
    'requires_special_handling': requiresSpecialHandling,
    'handling_notes': handlingNotes,
    'cancellation_conditions': cancellationConditions,
  };

  DeliveryRequirement copyWith({
    String? requiredVehicleType,
    double? minimumCapacityKg,
    String? handlingNotes,
  }) => DeliveryRequirement(
    requirementId: requirementId,
    deliveryId: deliveryId,
    requiredVehicleType: requiredVehicleType ?? this.requiredVehicleType,
    minimumCapacityKg: minimumCapacityKg ?? this.minimumCapacityKg,
    packageLengthCm: packageLengthCm,
    packageWidthCm: packageWidthCm,
    packageHeightCm: packageHeightCm,
    requiresCooling: requiresCooling,
    requiresFragileHandling: requiresFragileHandling,
    requiresWaterproofCover: requiresWaterproofCover,
    requiresSpecialHandling: requiresSpecialHandling,
    handlingNotes: handlingNotes ?? this.handlingNotes,
    cancellationConditions: cancellationConditions,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryRequirement && other.requirementId == requirementId;
  @override
  int get hashCode => requirementId.hashCode;
}
