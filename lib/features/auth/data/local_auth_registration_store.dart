import 'dart:collection';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/password_hasher.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';

class LocalAuthRegistrationStore {
  final List<RegisteredAccount> _accounts = <RegisteredAccount>[];
  late final List<RegisteredAccount> _accountsView = UnmodifiableListView(
    _accounts,
  );
  static const PasswordHasher _passwordHasher = PasswordHasher();

  List<RegisteredAccount> get accounts => _accountsView;

  Future<RegisteredAccount?> authenticate(
    String identifier,
    String password,
  ) async {
    final normalizedIdentifier = _normalizeIdentifier(identifier);
    for (final account in _accounts) {
      if (_matchesIdentifier(account, normalizedIdentifier) &&
          _passwordHasher.verify(
            password: password,
            hash: account.passwordHash,
            salt: account.passwordSalt,
          )) {
        return account;
      }
    }
    return null;
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final index = _accounts.indexWhere(
      (account) =>
          account.email == normalizedEmail &&
          _passwordHasher.verify(
            password: currentPassword,
            hash: account.passwordHash,
            salt: account.passwordSalt,
          ),
    );
    if (index < 0) {
      throw const AuthRegistrationException('Current password is incorrect.');
    }
    if (newPassword.length < 8) {
      throw const AuthRegistrationException(
        'Use a password with at least 8 characters.',
      );
    }
    final hashedPassword = _passwordHasher.hash(newPassword);
    _accounts[index] = _accounts[index].copyWith(
      passwordHash: hashedPassword.value,
      passwordSalt: hashedPassword.salt,
    );
  }

  Future<RegisteredAccount> register(
    SignUpAccountData data,
    AuthRole role, {
    bool isRiderApplication = false,
  }) async {
    final email = data.email.trim().toLowerCase();
    final phoneNumber = _normalizePhone(data.phoneNumber);
    if (_accounts.any(
      (account) =>
          account.email == email ||
          (phoneNumber != null &&
              _normalizePhone(account.phoneNumber) == phoneNumber),
    )) {
      throw const AuthRegistrationException(
        'An account with this email already exists.',
      );
    }
    final hashedPassword = _passwordHasher.hash(data.password);
    final account = RegisteredAccount(
      id: 'account-${DateTime.now().microsecondsSinceEpoch}',
      firstName: data.firstName.trim(),
      lastName: data.lastName.trim(),
      email: email,
      passwordHash: hashedPassword.value,
      passwordSalt: hashedPassword.salt,
      role: role.value,
      accountStatus: isRiderApplication ? 'pending' : 'active',
      verificationStatus: isRiderApplication || role == AuthRole.farmer
          ? 'pending'
          : null,
      extensionName: _normalizeOptionalText(data.extensionName),
      phoneNumber: phoneNumber,
      dateOfBirth: _normalizeOptionalText(data.dateOfBirth),
      shippingAddress: _normalizeOptionalText(data.shippingAddress),
    );
    _accounts.add(account);
    return account;
  }

  RegisteredAccount? accountById(String id) {
    for (final account in _accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  RegisteredAccount? updateShippingAddress(
    String id,
    String address, {
    double? latitude,
    double? longitude,
  }) {
    final index = _accounts.indexWhere((account) => account.id == id);
    if (index < 0) return null;
    final account = _accounts[index].copyWith(
      shippingAddress: address.trim(),
      shippingLatitude: latitude,
      shippingLongitude: longitude,
    );
    _accounts[index] = account;
    return account;
  }

  void clear() => _accounts.clear();

  bool _matchesIdentifier(RegisteredAccount account, String identifier) =>
      account.email == identifier ||
      _normalizePhone(account.phoneNumber) == identifier;

  String _normalizeIdentifier(String value) {
    final trimmed = value.trim();
    if (trimmed.contains('@')) return trimmed.toLowerCase();
    return _normalizePhone(trimmed) ?? '';
  }

  String? _normalizePhone(String? value) {
    if (value == null) return null;
    final philippineNumber = PhilippinePhoneNumber.normalize(value);
    if (philippineNumber != null) return philippineNumber;
    var digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('63') && digits.length == 12) {
      digits = '0${digits.substring(2)}';
    }
    return digits.isEmpty ? null : digits;
  }

  String? _normalizeOptionalText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}
