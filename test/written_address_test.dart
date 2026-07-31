import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';
import 'package:agresell_app/core/utils/written_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a readable Philippine address', () {
    expect(WrittenAddress.isValid('Purok 5, Lianga, Surigao del Sur'), isTrue);
  });

  test('rejects latitude and longitude used as an address', () {
    expect(WrittenAddress.isValid('8.6335, 126.0932'), isFalse);
    expect(WrittenAddress.isValid('(8.6335, 126.0932)'), isFalse);
    expect(WrittenAddress.valueOrNull('8.6335, 126.0932'), isNull);
  });

  test('profile validation explains that a written address is required', () {
    const profile = UserProfile(
      name: 'Buyer One',
      email: 'buyer@example.com',
      address: '',
      phoneNumber: '09123456789',
      gender: '',
      dateOfBirth: '',
    );

    final result = ProfileEditValidator.validateProfile(
      baseProfile: profile,
      name: profile.name,
      email: profile.email,
      address: '8.6335, 126.0932',
      phoneNumber: profile.phoneNumber,
    );

    expect(
      result.errorMessage,
      'Enter a written address, not latitude and longitude.',
    );
  });
}
