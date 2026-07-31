import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/core/utils/profile_identity_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = UserProfile(
    name: 'Buyer One',
    email: 'buyer@example.com',
    address: '',
    phoneNumber: '09123456789',
    gender: '',
    dateOfBirth: 'January 15, 2000',
    firstName: 'Buyer',
    lastName: 'One',
  );

  test('updates the same identity fields collected during signup', () {
    final result = ProfileIdentityValidator.validate(
      baseProfile: profile,
      firstName: 'Maria',
      lastName: 'Santos',
      extensionName: 'Jr.',
      phoneNumber: '09171234567',
      dateOfBirth: ProfileBirthDate.parse('2001-02-03'),
      email: 'maria@example.com',
    );

    expect(result.errorMessage, isNull);
    expect(result.profile?.name, 'Maria Santos Jr.');
    expect(result.profile?.firstName, 'Maria');
    expect(result.profile?.lastName, 'Santos');
    expect(result.profile?.extensionName, 'Jr.');
    expect(result.profile?.dateOfBirth, 'February 3, 2001');
  });

  test('requires a complete signup identity', () {
    final result = ProfileIdentityValidator.validate(
      baseProfile: profile,
      firstName: profile.firstName,
      lastName: profile.lastName,
      extensionName: '',
      phoneNumber: profile.phoneNumber,
      dateOfBirth: ProfileBirthDate.parse(''),
      email: profile.email,
    );

    expect(result.errorMessage, 'Date of Birth is required.');
  });
}
