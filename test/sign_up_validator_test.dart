import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/domain/sign_up_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhilippinePhoneNumber', () {
    test('accepts local mobile formats and normalizes for storage', () {
      expect(PhilippinePhoneNumber.isValid('09171234567'), isTrue);
      expect(PhilippinePhoneNumber.isValid('+639171234567'), isTrue);
      expect(PhilippinePhoneNumber.normalize('0917 123 4567'), '+639171234567');
      expect(PhilippinePhoneNumber.display('+639171234567'), '09171234567');
    });

    test('normalizes common device-provided Philippine formats', () {
      expect(
        PhilippinePhoneNumber.normalizeDeviceNumber('639171234567'),
        '+639171234567',
      );
      expect(
        PhilippinePhoneNumber.normalizeDeviceNumber('9171234567'),
        '+639171234567',
      );
      expect(
        PhilippinePhoneNumber.normalizeDeviceNumber('+6309171234567'),
        '+639171234567',
      );
      expect(
        PhilippinePhoneNumber.normalizeDeviceNumber('0063 917 123 4567'),
        '+639171234567',
      );
      expect(
        PhilippinePhoneNumber.normalizeDeviceNumber(
          'tel:09638330462;phone-context=+63',
        ),
        '+639638330462',
      );
    });

    test('rejects non-Philippine and malformed numbers', () {
      expect(PhilippinePhoneNumber.isValid('+14155552671'), isFalse);
      expect(PhilippinePhoneNumber.isValid('08171234567'), isFalse);
      expect(PhilippinePhoneNumber.isValid('0917123456'), isFalse);
    });
  });

  group('SignUpValidator', () {
    test('accepts complete buyer or farmer identity details', () {
      expect(_validate(), isNull);
    });

    test('requires a valid mobile number', () {
      expect(
        _validate(contactNumber: '+14155552671'),
        contains('valid mobile number'),
      );
    });

    test('requires a valid non-future date of birth', () {
      expect(
        _validate(dateOfBirth: '2999-01-01'),
        'Select a valid date of birth.',
      );
    });

    test('requires a gender selection', () {
      expect(_validate(gender: ''), 'Select your gender.');
    });

    test('requires the same strong password used by rider registration', () {
      expect(_validate(password: 'password123'), 'Password is too weak.');
    });
  });
}

String? _validate({
  String contactNumber = '09171234567',
  String dateOfBirth = '2000-01-01',
  String gender = 'Female',
  String shippingAddress = 'Purok 5, Lianga, Surigao del Sur',
  String password = 'Password123!',
}) {
  return SignUpValidator.validate(
    firstName: 'Ana',
    lastName: 'Reyes',
    contactNumber: contactNumber,
    dateOfBirth: dateOfBirth,
    gender: gender,
    shippingAddress: shippingAddress,
    email: 'ana@example.com',
    password: password,
    confirmPassword: password,
    agreesToPolicy: true,
  );
}
