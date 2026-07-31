import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RiderMapView {
  const RiderMapView({
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.rotation,
  });

  final double latitude;
  final double longitude;
  final double zoom;
  final double rotation;
}

class RiderMapViewCache {
  RiderMapViewCache({this.preferences});
  static const _key = 'rider_map_view_v1';
  final SharedPreferences? preferences;

  Future<RiderMapView?> load() async {
    try {
      final encoded = (await _instance).getString(_key);
      if (encoded == null) return null;
      final value = Map<String, Object?>.from(jsonDecode(encoded) as Map);
      return RiderMapView(
        latitude: (value['latitude'] as num).toDouble(),
        longitude: (value['longitude'] as num).toDouble(),
        zoom: (value['zoom'] as num).toDouble(),
        rotation: (value['rotation'] as num).toDouble(),
      );
    } on Object {
      return null;
    }
  }

  Future<void> save(RiderMapView view) async {
    await (await _instance).setString(
      _key,
      jsonEncode({
        'latitude': view.latitude,
        'longitude': view.longitude,
        'zoom': view.zoom,
        'rotation': view.rotation,
      }),
    );
  }

  Future<SharedPreferences> get _instance async =>
      preferences ?? await SharedPreferences.getInstance();
}
