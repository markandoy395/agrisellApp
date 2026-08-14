import 'package:agresell_app/core/utils/map_coordinates.dart';

import 'delivery_location.dart';
import 'delivery_status_update.dart';

abstract final class GoogleMapsRoute {
  static bool hasValidDestination(DeliveryLocation destination) =>
      MapCoordinates.isValid(
        latitude: destination.latitude,
        longitude: destination.longitude,
      );

  static Uri? directionsUri({
    required DeliveryStatusLocation? origin,
    required DeliveryLocation destination,
    DateTime? now,
  }) {
    if (!(origin?.isUsableForPickup(now: now) ?? false) ||
        !hasValidDestination(destination)) {
      return null;
    }
    return Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'origin': '${origin!.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'travelmode': 'driving',
      'dir_action': 'navigate',
    });
  }
}
