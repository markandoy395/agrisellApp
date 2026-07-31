class FarmModel {
  const FarmModel({
    required this.id,
    required this.farmerId,
    required this.name,
    required this.mainCrops,
    this.location,
    this.barangay,
    this.cityMunicipality,
    this.province,
    this.latitude,
    this.longitude,
    this.size,
    this.sizeUnit,
    this.farmingType,
    this.irrigationType,
    this.ownershipType,
    this.imageUrl,
  });

  final int id;
  final int farmerId;
  final String name;
  final List<String> mainCrops;
  final String? location;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final double? size;
  final String? sizeUnit;
  final String? farmingType;
  final String? irrigationType;
  final String? ownershipType;
  final String? imageUrl;

  factory FarmModel.fromJson(Map<String, dynamic> json) => FarmModel(
    id: json['farm_id'] as int,
    farmerId: json['farmer_user_id'] as int,
    name: (json['farm_name'] as String? ?? '').trim(),
    mainCrops: (json['main_crops'] as List<Object?>? ?? const <Object?>[])
        .map((crop) => crop.toString().trim())
        .where((crop) => crop.isNotEmpty)
        .toList(growable: false),
    location: _value(json['farm_location']),
    barangay: _value(json['barangay']),
    cityMunicipality: _value(json['city_municipality']),
    province: _value(json['province']),
    latitude: _double(json['gps_lat']),
    longitude: _double(json['gps_long']),
    size: _double(json['farm_size_hectares']),
    sizeUnit: _value(json['farm_size_unit']),
    farmingType: _value(json['farming_type']),
    irrigationType: _value(json['irrigation_type']),
    ownershipType: _value(json['ownership_type']),
    imageUrl: _firstText(
      json['farm_images'] as List<Object?>? ?? const <Object?>[],
    ),
  );
}

String? _value(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

double? _double(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

String? _firstText(Iterable<Object?> values) {
  for (final value in values) {
    final text = _value(value);
    if (text != null) return text;
  }
  return null;
}
