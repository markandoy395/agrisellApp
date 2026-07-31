import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_validator.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Farmer account validation reports invalid values while typing', () {
    expect(FarmerSignupValidator.email('farmer'), isNotNull);
    expect(FarmerSignupValidator.password('weak'), isNotNull);
    expect(
      FarmerSignupValidator.passwordConfirmation('Password123!', 'different'),
      isNotNull,
    );
  });

  test(
    'Farmer signup metadata carries profile and farm data without email',
    () {
      const data = FarmerSignupData(
        email: 'farmer@example.com',
        password: 'Password123!',
        firstName: 'Ana',
        lastName: 'Reyes',
        phoneNumber: '+639171234567',
        farmName: 'Ana Farm',
        mainCrops: ['okra', ' tomato '],
        barangay: 'San Roque',
        cityMunicipality: 'Tarlac City',
        province: 'Tarlac',
        farmLocation: 'Barangay San Roque, Tarlac City',
        latitude: 15.4755,
        longitude: 120.5963,
        yearsOfExperience: 5,
        farmSize: 2.5,
        farmSizeUnit: 'hectares',
      );

      final metadata = data.toAuthMetadata();

      expect(metadata['requested_role'], 'farmer');
      expect(metadata['farm_name'], 'Ana Farm');
      expect(metadata['main_crops'], ['okra', ' tomato ']);
      expect(metadata['total_crops'], 2);
      expect(metadata['years_of_experience'], 5);
      expect(metadata['farm_location'], 'Barangay San Roque, Tarlac City');
      expect(metadata['latitude'], 15.4755);
      expect(metadata['longitude'], 120.5963);
      expect(metadata.containsKey('email'), isFalse);
    },
  );

  test('email-confirmation response explains the next step', () {
    const error = AuthEmailConfirmationRequired();

    expect(
      error.message,
      'We sent an OTP to your email. Verify it, then log in to finish signing up.',
    );
  });

  test('Farm validation requires a pinned location and whole years', () {
    expect(FarmerSignupValidator.farmCoordinates('', ''), isNotNull);
    expect(
      FarmerSignupValidator.farmCoordinates('14.5995', '120.9842'),
      isNull,
    );
    expect(FarmerSignupValidator.farmCoordinates('91', '120'), isNotNull);
    expect(FarmerSignupValidator.farmCoordinates('14', '181'), isNotNull);
    expect(FarmerSignupValidator.wholeNumber('3.5', 'experience'), isNotNull);
    expect(FarmerSignupValidator.wholeNumber('3', 'experience'), isNull);
    expect(FarmerSignupValidator.number('', 'farm size'), isNotNull);
    expect(FarmerSignupValidator.number('0', 'farm size'), isNotNull);
    expect(FarmerSignupValidator.number('2.5', 'farm size'), isNull);
  });
}
