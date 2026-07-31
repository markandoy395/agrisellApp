import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

class RiderRegistrationPayload {
  const RiderRegistrationPayload._();

  static Map<String, Object?> fromRegistration(RiderRegistration registration) {
    return <String, Object?>{
      'first_name': registration.firstName.trim(),
      'middle_name': registration.middleName.trim(),
      'last_name': registration.lastName.trim(),
      'date_of_birth': registration.dateOfBirth.trim(),
      'gender': registration.gender.trim(),
      'contact_number': registration.contactNumber.trim(),
      'gps_lat': registration.gpsLatitude,
      'gps_long': registration.gpsLongitude,
      'gps_accuracy_meters': registration.gpsAccuracyMeters,
      'location_captured_at': registration.locationCapturedAt
          ?.toUtc()
          .toIso8601String(),
      'location_label': registration.locationLabel.trim(),
      'location_notes': registration.locationNotes.trim(),
      'vehicle_type': registration.vehicleType?.name,
      'vehicle_plate_number': registration.vehiclePlateNumber
          .trim()
          .toUpperCase(),
      'license_number': registration.licenseNumber.trim().toUpperCase(),
      // The selected file is local to the device. The registration service
      // uploads it separately, then writes the resulting storage path here.
      'profile_photo_url': null,
      'accepted_terms': registration.acceptsTerms,
      'accepted_privacy': registration.acceptsPrivacy,
      'confirmed_accuracy': registration.confirmsAccuracy,
      if ((registration.logisticsCompanyId ?? '').trim().isNotEmpty)
        'logistics_company_id': registration.logisticsCompanyId!.trim(),
    };
  }
}
