import 'package:agresell_app/features/rider/dashboard/domain/rider_availability_state.dart';

extension RiderAvailabilityWarningPresentation on RiderAvailabilityWarning {
  String get displayMessage => switch (this) {
    RiderAvailabilityWarning.verificationRequired =>
      'Rider verification is required before going online.',
    RiderAvailabilityWarning.unauthorizedRider =>
      'Sign in to your Rider account before changing availability.',
    RiderAvailabilityWarning.noInternet =>
      'Connect to the internet before changing availability.',
    RiderAvailabilityWarning.backendUnavailable =>
      'AgriSell is temporarily unavailable. Your confirmed status was kept.',
    RiderAvailabilityWarning.gpsDisabled =>
      'Turn on GPS to go online and receive location-based work.',
    RiderAvailabilityWarning.locationPermissionDenied =>
      'Allow location access before going online.',
    RiderAvailabilityWarning.locationPermissionDeniedForever =>
      'Location access is blocked. Open app settings to allow it.',
    RiderAvailabilityWarning.approximateLocation =>
      'Turn on precise location in app settings before going online.',
    RiderAvailabilityWarning.poorGpsAccuracy =>
      'GPS accuracy is weak. Move to an open area for better results.',
    RiderAvailabilityWarning.locationTimeout =>
      'Location took too long. Check your GPS signal and try again.',
    RiderAvailabilityWarning.locationUnavailable =>
      'Your location is unavailable. Check GPS and try again.',
    RiderAvailabilityWarning.activeDelivery =>
      'You cannot go offline while an active delivery is in progress.',
    RiderAvailabilityWarning.synchronizationFailed =>
      'Availability was not updated. Your previous status was restored.',
  };
}
