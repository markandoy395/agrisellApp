enum RiderVehicleVerificationStatus { pending, verified, rejected }

class RiderVehicle {
  const RiderVehicle({
    required this.vehicleId,
    required this.riderId,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleColor,
    required this.plateNumber,
    required this.capacityKg,
    this.vehicleBrand,
    this.registrationNumber,
    this.handlingCapability,
    this.verificationStatus = RiderVehicleVerificationStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  final String vehicleId;
  final String riderId;
  final String vehicleType;
  final String? vehicleBrand;
  final String vehicleModel;
  final String vehicleColor;
  final String plateNumber;
  final String? registrationNumber;
  final double capacityKg;
  final String? handlingCapability;
  final RiderVehicleVerificationStatus verificationStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RiderVehicle.fromJson(Map<String, Object?> json) => RiderVehicle(
    vehicleId: _text(json['vehicle_id']),
    riderId: _text(json['rider_id']),
    vehicleType: _text(json['vehicle_type']),
    vehicleBrand: _nullableText(json['vehicle_brand']),
    vehicleModel: _text(json['vehicle_model']),
    vehicleColor: _text(json['vehicle_color']),
    plateNumber: _text(json['plate_number']),
    registrationNumber: _nullableText(json['registration_number']),
    capacityKg: _number(json['capacity_kg']),
    handlingCapability: _nullableText(json['handling_capability']),
    verificationStatus: RiderVehicleVerificationStatus.values.firstWhere(
      (item) => item.name == json['verification_status'],
      orElse: () => RiderVehicleVerificationStatus.pending,
    ),
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
  );

  Map<String, Object?> toJson() => {
    if (vehicleId.isNotEmpty) 'vehicle_id': vehicleId,
    'rider_id': riderId,
    'vehicle_type': vehicleType.trim(),
    'vehicle_brand': _blankToNull(vehicleBrand),
    'vehicle_model': vehicleModel.trim(),
    'vehicle_color': vehicleColor.trim(),
    'plate_number': plateNumber.trim().toUpperCase(),
    'registration_number': _blankToNull(registrationNumber)?.toUpperCase(),
    'capacity_kg': capacityKg,
    'handling_capability': _blankToNull(handlingCapability),
    'verification_status': verificationStatus.name,
  };

  RiderVehicle copyWith({
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleColor,
    String? plateNumber,
    String? registrationNumber,
    double? capacityKg,
    String? handlingCapability,
    RiderVehicleVerificationStatus? verificationStatus,
  }) => RiderVehicle(
    vehicleId: vehicleId,
    riderId: riderId,
    vehicleType: vehicleType ?? this.vehicleType,
    vehicleBrand: vehicleBrand ?? this.vehicleBrand,
    vehicleModel: vehicleModel ?? this.vehicleModel,
    vehicleColor: vehicleColor ?? this.vehicleColor,
    plateNumber: plateNumber ?? this.plateNumber,
    registrationNumber: registrationNumber ?? this.registrationNumber,
    capacityKg: capacityKg ?? this.capacityKg,
    handlingCapability: handlingCapability ?? this.handlingCapability,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is RiderVehicle &&
      other.vehicleId == vehicleId &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(vehicleId, updatedAt);
}

String _text(Object? value) => value?.toString().trim() ?? '';
String? _nullableText(Object? value) => _blankToNull(value?.toString());
String? _blankToNull(String? value) => switch (value?.trim()) {
  final text? when text.isNotEmpty => text,
  _ => null,
};
double _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
DateTime? _date(Object? value) =>
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
