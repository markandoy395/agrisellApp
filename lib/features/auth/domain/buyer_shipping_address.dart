class BuyerShippingAddress {
  const BuyerShippingAddress({
    required this.address,
    this.latitude,
    this.longitude,
  });

  final String address;
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;

  BuyerShippingAddress copyWith({
    String? address,
    double? latitude,
    double? longitude,
  }) => BuyerShippingAddress(
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
  );
}
