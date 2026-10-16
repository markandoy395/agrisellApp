import 'package:latlong2/latlong.dart';

LatLng? riderDetailMapPoint(double? latitude, double? longitude) {
  if (latitude == null ||
      longitude == null ||
      !latitude.isFinite ||
      !longitude.isFinite ||
      latitude < -90 ||
      latitude > 90 ||
      longitude < -180 ||
      longitude > 180)
    return null;
  return LatLng(latitude, longitude);
}
