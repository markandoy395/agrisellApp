class RiderLocation {
  const RiderLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.timestamp,
    this.locationId,
    this.riderId,
    this.altitudeMeters,
    this.speedMetersPerSecond = 0,
    this.headingDegrees = 0,
    this.isMocked = false,
    this.isApproximate = false,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime timestamp;
  final String? locationId;
  final String? riderId;
  final double? altitudeMeters;
  final double speedMetersPerSecond;
  final double headingDegrees;
  final bool isMocked;
  final bool isApproximate;

  Map<String, Object> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracyMeters': accuracyMeters,
    'altitudeMeters': ?altitudeMeters,
    'speedMetersPerSecond': speedMetersPerSecond,
    'headingDegrees': headingDegrees,
    'isMocked': isMocked,
    'isApproximate': isApproximate,
    'timestamp': timestamp.toUtc().toIso8601String(),
  };

  factory RiderLocation.fromJson(Map<String, Object?> json) => RiderLocation(
    locationId: _nullableText(json['locationId']),
    riderId: _nullableText(json['riderId']),
    latitude: _number(json['latitude']),
    longitude: _number(json['longitude']),
    accuracyMeters: _number(json['accuracyMeters']),
    altitudeMeters: _nullableNumber(json['altitudeMeters']),
    speedMetersPerSecond: _number(json['speedMetersPerSecond']),
    headingDegrees: _number(json['headingDegrees']),
    isMocked: json['isMocked'] as bool? ?? false,
    isApproximate: json['isApproximate'] as bool? ?? false,
    timestamp: _date(json['timestamp']).toLocal(),
  );

  factory RiderLocation.fromDatabaseJson(Map<String, Object?> json) =>
      RiderLocation(
        locationId: _nullableText(json['location_id']),
        riderId: _nullableText(json['rider_id']),
        latitude: _number(json['latitude']),
        longitude: _number(json['longitude']),
        accuracyMeters: _number(json['accuracy_meters']),
        speedMetersPerSecond: _number(json['speed_kph']) / 3.6,
        headingDegrees: _number(json['heading']),
        timestamp: _date(json['location_updated_at']).toLocal(),
      );

  Map<String, Object?> toDatabaseJson() => {
    if (locationId?.isNotEmpty ?? false) 'location_id': locationId,
    if (riderId?.isNotEmpty ?? false) 'rider_id': riderId,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy_meters': accuracyMeters,
    'heading': headingDegrees,
    'speed_kph': speedMetersPerSecond * 3.6,
    'location_updated_at': timestamp.toUtc().toIso8601String(),
  };

  RiderLocation copyWith({
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    DateTime? timestamp,
    double? altitudeMeters,
    double? speedMetersPerSecond,
    double? headingDegrees,
    bool? isMocked,
    bool? isApproximate,
  }) => RiderLocation(
    locationId: locationId,
    riderId: riderId,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    accuracyMeters: accuracyMeters ?? this.accuracyMeters,
    timestamp: timestamp ?? this.timestamp,
    altitudeMeters: altitudeMeters ?? this.altitudeMeters,
    speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
    headingDegrees: headingDegrees ?? this.headingDegrees,
    isMocked: isMocked ?? this.isMocked,
    isApproximate: isApproximate ?? this.isApproximate,
  );

  @override
  bool operator ==(Object other) =>
      other is RiderLocation &&
      other.riderId == riderId &&
      other.latitude == latitude &&
      other.longitude == longitude &&
      other.timestamp == timestamp;

  @override
  int get hashCode => Object.hash(riderId, latitude, longitude, timestamp);
}

double _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;
double? _nullableNumber(Object? value) => value == null
    ? null
    : value is num
    ? value.toDouble()
    : double.tryParse(value.toString());
String? _nullableText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime _date(Object? value) => value is DateTime
    ? value
    : DateTime.tryParse(value?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
