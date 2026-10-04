import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_account_fixture.dart';

export 'package:agresell_app/features/auth/domain/sign_up_account_data.dart'
    show AuthRole;

/// Opt in only for tests of authenticated workflows, never authentication denial.
void configureAuthenticatedTests({AuthRole role = AuthRole.buyer}) {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
    final account = await registerTestAccount(role: role);
    await AuthSessionService.instance.start(account, rememberMe: false);
    expect(AuthSessionService.instance.isAuthenticated, isTrue);
  });

  tearDown(() {
    AuthSessionService.instance.clearMemoryForTesting();
    AuthRegistrationService.instance.clearForTesting();
  });
}
