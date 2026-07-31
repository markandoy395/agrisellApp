import 'delivery_json.dart';

enum DeliveryLocationType {
  pickup,
  dropoff;

  static DeliveryLocationType fromBackendValue(Object? value) =>
      values.firstWhere(
        (item) => item.name == value,
        orElse: () => throw FormatException('Unknown location type: $value'),
      );
}

class DeliveryLocation {
  const DeliveryLocation({
    required this.address,
    this.latitude,
    this.longitude,
    this.locationId,
    this.deliveryId,
    this.locationType,
    this.contactName,
    this.contactNumber,
    this.instructions,
    this.sequenceNumber = 1,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryLocation.fromJson(Map<String, Object?> json) {
    final latitude = deliveryDouble(json['latitude']);
    final longitude = deliveryDouble(json['longitude']);
    if (latitude == null || longitude == null) {
      throw const FormatException(
        'Delivery location coordinates are required.',
      );
    }
    return DeliveryLocation(
      locationId: deliveryString(json['location_id']),
      deliveryId: deliveryString(json['delivery_id']),
      locationType: DeliveryLocationType.fromBackendValue(
        json['location_type'],
      ),
      address: deliveryString(json['address']),
      latitude: latitude,
      longitude: longitude,
      contactName: json['contact_name'] as String?,
      contactNumber: json['contact_number'] as String?,
      instructions: json['instructions'] as String?,
      sequenceNumber: deliveryInt(json['sequence_number']) ?? 1,
      createdAt: deliveryDateTime(json['created_at']),
      updatedAt: deliveryDateTime(json['updated_at']),
    );
  }

  final String? locationId;
  final String? deliveryId;
  final DeliveryLocationType? locationType;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactNumber;
  final String? instructions;
  final int sequenceNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasCoordinates => latitude != null && longitude != null;

  Map<String, Object?> toJson() => {
    if (locationId != null) 'location_id': locationId,
    if (deliveryId != null) 'delivery_id': deliveryId,
    if (locationType != null) 'location_type': locationType!.name,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'contact_name': contactName,
    'contact_number': contactNumber,
    'instructions': instructions,
    'sequence_number': sequenceNumber,
    if (createdAt != null) 'created_at': createdAt!.toUtc().toIso8601String(),
    if (updatedAt != null) 'updated_at': updatedAt!.toUtc().toIso8601String(),
  };

  DeliveryLocation copyWith({
    String? address,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactNumber,
    String? instructions,
    int? sequenceNumber,
  }) => DeliveryLocation(
    locationId: locationId,
    deliveryId: deliveryId,
    locationType: locationType,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    contactName: contactName ?? this.contactName,
    contactNumber: contactNumber ?? this.contactNumber,
    instructions: instructions ?? this.instructions,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is DeliveryLocation &&
      other.locationId == locationId &&
      other.deliveryId == deliveryId &&
      other.locationType == locationType &&
      other.address == address &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.sequenceNumber == sequenceNumber;

  @override
  int get hashCode => Object.hash(
    locationId,
    deliveryId,
    locationType,
    address,
    latitude,
    longitude,
    sequenceNumber,
  );
}
