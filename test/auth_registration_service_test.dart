import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AuthRegistrationService.instance.clearForTesting);
  tearDown(AuthRegistrationService.instance.clearForTesting);

  test(
    'duplicate email and phone registration errors name the field',
    () async {
      await AuthRegistrationService.instance.register(
        const SignUpAccountData(
          firstName: 'Ana',
          lastName: 'Reyes',
          email: 'ana@example.com',
          password: 'password123',
          phoneNumber: '09171234567',
        ),
        AuthRole.farmer,
      );

      await expectLater(
        AuthRegistrationService.instance.register(
          const SignUpAccountData(
            firstName: 'Ana',
            lastName: 'Santos',
            email: 'ANA@example.com',
            password: 'password123',
            phoneNumber: '09170000000',
          ),
          AuthRole.farmer,
        ),
        throwsA(
          isA<AuthRegistrationException>().having(
            (error) => error.message,
            'message',
            'An account with this email already exists.',
          ),
        ),
      );

      await expectLater(
        AuthRegistrationService.instance.register(
          const SignUpAccountData(
            firstName: 'Ben',
            lastName: 'Santos',
            email: 'ben@example.com',
            password: 'password123',
            phoneNumber: '+639171234567',
          ),
          AuthRole.farmer,
        ),
        throwsA(
          isA<AuthRegistrationException>().having(
            (error) => error.message,
            'message',
            'An account with this phone number already exists.',
          ),
        ),
      );
    },
  );
}
