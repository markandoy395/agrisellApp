import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

Future<RegisteredAccount> registerTestAccount({
  AuthRole role = AuthRole.farmer,
  String email = 'account.fixture@example.com',
  String phoneNumber = '09123456789',
}) {
  return AuthRegistrationService.instance.register(
    SignUpAccountData(
      firstName: 'Test',
      lastName: 'Account',
      email: email,
      password: 'password123',
      phoneNumber: phoneNumber,
      dateOfBirth: '2000-01-15',
    ),
    role,
  );
}
