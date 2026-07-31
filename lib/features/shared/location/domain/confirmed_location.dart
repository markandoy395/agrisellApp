class ConfirmedLocation {
  const ConfirmedLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.capturedAt,
    this.address,
    this.notes,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime capturedAt;
  final String? address;
  final String? notes;

  String get coordinateLabel =>
      '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';

  Map<String, Object?> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': accuracyMeters,
    'capturedAt': capturedAt.toUtc().toIso8601String(),
    'address': address,
    'notes': notes,
  };

  factory ConfirmedLocation.fromJson(Map<String, Object?> json) {
    return ConfirmedLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num).toDouble(),
      capturedAt: DateTime.parse(json['capturedAt'] as String).toLocal(),
      address: json['address'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

enum LocationOwnerRole { farmer, buyer, rider }
