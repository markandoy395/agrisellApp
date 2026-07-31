import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/utils/map_coordinates.dart';

class NominatimGeocodingService {
  NominatimGeocodingService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<LatLng?> geocode(String address) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'format': 'jsonv2',
      'limit': '1',
      'countrycodes': 'ph',
      'accept-language': 'en',
      'q': address,
    });
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) return null;
    final values = jsonDecode(response.body) as List<Object?>;
    if (values.isEmpty) return null;
    final value = values.first as Map<String, Object?>;
    return _point(value['lat'], value['lon']);
  }

  Future<String?> reverseGeocode(LatLng point) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'format': 'jsonv2',
      'lat': point.latitude.toString(),
      'lon': point.longitude.toString(),
      'zoom': '18',
      'accept-language': 'en',
    });
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != 200) return null;
    final value = jsonDecode(response.body) as Map<String, Object?>;
    final address = value['display_name']?.toString().trim() ?? '';
    return address.isEmpty ? null : address;
  }

  LatLng? _point(Object? latitude, Object? longitude) {
    final lat = double.tryParse(latitude?.toString() ?? '');
    final lon = double.tryParse(longitude?.toString() ?? '');
    return MapCoordinates.isValid(latitude: lat, longitude: lon)
        ? LatLng(lat!, lon!)
        : null;
  }

  Map<String, String> get _headers => const {
    'User-Agent': 'AgriSell address selector',
    'Accept': 'application/json',
  };
}
