class RiderNearbyFarm {
  const RiderNearbyFarm({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    this.mainCrops = const <String>[],
  });

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final List<String> mainCrops;

  String get cropsLabel =>
      mainCrops.isEmpty ? 'Farm pickup location' : mainCrops.take(3).join(', ');
}
