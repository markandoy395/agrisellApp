import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/profile/data/rider_registration_payload.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

void main() {
  test('rider application contains only Rider-specific registration data', () {
    final registration = RiderRegistration(
      firstName: 'Ana',
      middleName: 'M',
      lastName: 'Reyes',
      dateOfBirth: '1995-04-12',
      gender: 'Female',
      contactNumber: '09171234567',
      email: 'ANA@EXAMPLE.COM',
      gpsLatitude: 8.48,
      gpsLongitude: 124.65,
      gpsAccuracyMeters: 12.5,
      locationCapturedAt: DateTime.utc(2026, 7, 15, 8, 30),
      locationLabel: 'Cagayan de Oro City',
      addressLine: '12 Rizal Street',
      barangay: 'Cogon',
      cityMunicipality: 'Cagayan de Oro City',
      province: 'Misamis Oriental',
      postalCode: '9000',
      locationNotes: 'Meet at the public market.',
      vehicleType: RiderVehicleType.motorcycle,
      vehiclePlateNumber: 'abc 1234',
      licenseNumber: 'n01-23-456789',
      profilePhotoPath: 'device-only/photo.jpg',
      password: 'Private123!',
      confirmPassword: 'Private123!',
      acceptsTerms: true,
      acceptsPrivacy: true,
      confirmsAccuracy: true,
    );
    final payload = RiderRegistrationPayload.fromRegistration(registration);

    expect(payload['vehicle_plate_number'], 'ABC 1234');
    expect(payload['license_number'], 'N01-23-456789');
    expect(payload['gps_lat'], 8.48);
    expect(payload['gps_long'], 124.65);
    expect(payload['gps_accuracy_meters'], 12.5);
    expect(payload['location_label'], 'Cagayan de Oro City');
    expect(payload['address_line'], '12 Rizal Street');
    expect(payload['barangay'], 'Cogon');
    expect(payload['city_municipality'], 'Cagayan de Oro City');
    expect(payload['province'], 'Misamis Oriental');
    expect(payload['postal_code'], '9000');
    expect(payload['location_notes'], 'Meet at the public market.');
    expect(payload['location_captured_at'], '2026-07-15T08:30:00.000Z');
    expect(payload['vehicle_type'], 'motorcycle');
    expect(payload['profile_photo_url'], isNull);
    expect(payload['accepted_terms'], isTrue);
    expect(payload['accepted_privacy'], isTrue);
    expect(payload['confirmed_accuracy'], isTrue);
    expect(payload.keys, {
      'first_name',
      'middle_name',
      'last_name',
      'date_of_birth',
      'gender',
      'contact_number',
      'gps_lat',
      'gps_long',
      'gps_accuracy_meters',
      'location_captured_at',
      'location_label',
      'address_line',
      'barangay',
      'city_municipality',
      'province',
      'postal_code',
      'location_notes',
      'vehicle_type',
      'vehicle_plate_number',
      'license_number',
      'profile_photo_url',
      'accepted_terms',
      'accepted_privacy',
      'confirmed_accuracy',
    });
    expect(payload, isNot(contains('email')));
    expect(payload, isNot(contains('password')));
    expect(payload, isNot(contains('confirm_password')));
    expect(payload, isNot(contains('capacity_kg')));
    expect(payload, isNot(contains('logistics_company_id')));
  });

  test('rider application includes a selected logistics company', () {
    const registration = RiderRegistration(
      firstName: 'Ana',
      middleName: '',
      lastName: 'Reyes',
      dateOfBirth: '1995-04-12',
      gender: 'Female',
      contactNumber: '09171234567',
      email: 'ana@example.com',
      gpsLatitude: 8.48,
      gpsLongitude: 124.65,
      vehicleType: RiderVehicleType.motorcycle,
      vehiclePlateNumber: 'ABC 1234',
      licenseNumber: 'N01-23-456789',
      profilePhotoPath: null,
      password: 'Private123!',
      confirmPassword: 'Private123!',
      acceptsTerms: true,
      acceptsPrivacy: true,
      confirmsAccuracy: true,
      logisticsCompanyId: '42',
    );

    expect(
      RiderRegistrationPayload.fromRegistration(
        registration,
      )['logistics_company_id'],
      '42',
    );
  });
}
