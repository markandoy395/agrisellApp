import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// Keeps all values passed into flutter_map finite and within its map bounds.
abstract final class RiderMapCameraPolicy {
  static const defaultZoom = 15.0;

  static bool isCoordinateValid(double latitude, double longitude) =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;

  static bool isCameraValid(MapCamera camera) =>
      isCoordinateValid(camera.center.latitude, camera.center.longitude) &&
      camera.zoom.isFinite &&
      camera.rotation.isFinite;

  /// flutter_map calculates tile pixels from this viewport. Moving a camera
  /// before it has a finite, non-zero size can produce NaN tile coordinates.
  static bool canMoveCamera(MapCamera camera) {
    final viewport = camera.nonRotatedSize;
    return isCameraValid(camera) &&
        viewport.width.isFinite &&
        viewport.height.isFinite &&
        viewport.width > 0 &&
        viewport.height > 0;
  }

  static double safeRotation(double rotation, {double fallback = 0}) {
    if (!rotation.isFinite) return fallback;
    return rotation.remainder(360);
  }

  static double safeZoom(
    double zoom, {
    double minimum = 4,
    double maximum = 19,
    double fallback = defaultZoom,
  }) {
    if (!zoom.isFinite) return fallback;
    return zoom.clamp(minimum, maximum).toDouble();
  }

  /// Returns fit padding that can never consume the map's entire viewport.
  static EdgeInsets? routeFitPadding(Size viewport) {
    if (!viewport.width.isFinite ||
        !viewport.height.isFinite ||
        viewport.width <= 0 ||
        viewport.height <= 0) {
      return null;
    }
    return EdgeInsets.fromLTRB(
      (viewport.width * 0.08).clamp(0, 40).toDouble(),
      (viewport.height * 0.18).clamp(0, 120).toDouble(),
      (viewport.width * 0.08).clamp(0, 40).toDouble(),
      (viewport.height * 0.30).clamp(0, 220).toDouble(),
    );
  }
}
