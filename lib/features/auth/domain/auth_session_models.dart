import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

class AuthSessionRestoreResult {
  const AuthSessionRestoreResult({
    required this.account,
    required this.wasExpired,
  });

  const AuthSessionRestoreResult.noSession()
    : account = null,
      wasExpired = false;

  const AuthSessionRestoreResult.expired() : account = null, wasExpired = true;

  final RegisteredAccount? account;
  final bool wasExpired;
}

class SavedAccountSessionException implements Exception {
  const SavedAccountSessionException(this.message);

  final String message;

  @override
  String toString() => message;
}
