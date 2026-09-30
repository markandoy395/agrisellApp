import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_validator.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_registration_choices.dart';
import 'package:agresell_app/features/farmer/registration/domain/philippine_crops.dart';
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
        farmSizeUnit: 'sq m',
        farmingType: 'Rice (Palay)',
        ownershipType: 'Registered Owner',
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
      expect(metadata['farm_size'], 2.5);
      expect(metadata['farm_size_unit'], 'sq m');
      expect(metadata['farming_type'], 'Rice (Palay)');
      expect(metadata['ownership_type'], 'Registered Owner');
      expect(metadata.containsKey('email'), isFalse);
    },
  );

  test('email-confirmation response explains the next step', () {
    const error = AuthEmailConfirmationRequired();

    expect(error.message, 'We sent a 6-digit OTP to your email.');
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

  test('Farm dropdowns accept only the defined choices', () {
    expect(
      FarmerSignupValidator.choice(
        'ha',
        FarmerRegistrationChoices.farmSizeUnits,
        'a unit',
      ),
      isNull,
    );
    expect(
      FarmerSignupValidator.choice(
        'hectares',
        FarmerRegistrationChoices.farmSizeUnits,
        'a unit',
      ),
      isNotNull,
    );
    expect(
      FarmerSignupValidator.choice(
        'Organic farming',
        FarmerRegistrationChoices.farmingTypes,
        'a type',
      ),
      isNotNull,
    );
    expect(
      FarmerSignupValidator.choice(
        'Tenant / Lessee',
        FarmerRegistrationChoices.landTenures,
        'a status',
      ),
      isNull,
    );
    expect(
      FarmerSignupValidator.choice(
        '',
        FarmerRegistrationChoices.landTenures,
        'a status',
      ),
      isNotNull,
    );
  });

  test('main crops require selections from the PSA crop list', () {
    expect(
      PhilippineCrops.names,
      containsAll(['Palay', 'Corn', 'Coconut', 'Tomato']),
    );
    expect(FarmerSignupValidator.mainCrops('Palay, Coconut'), isNull);
    expect(FarmerSignupValidator.mainCrops(''), isNotNull);
    expect(FarmerSignupValidator.mainCrops('Unknown crop'), isNotNull);
  });

  test('irrigation is optional but must be a listed type when selected', () {
    expect(
      FarmerSignupValidator.optionalChoice(
        '',
        FarmerRegistrationChoices.irrigationTypes,
        'an irrigation type',
      ),
      isNull,
    );
    expect(
      FarmerSignupValidator.optionalChoice(
        'Drip Irrigation',
        FarmerRegistrationChoices.irrigationTypes,
        'an irrigation type',
      ),
      isNull,
    );
    expect(
      FarmerSignupValidator.optionalChoice(
        'Unknown',
        FarmerRegistrationChoices.irrigationTypes,
        'an irrigation type',
      ),
      isNotNull,
    );
  });
}
