import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/auth/domain/buyer_shipping_address.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

class SupabaseAuthService {
  const SupabaseAuthService();

  SupabaseClient get _client => AgrisellSupabase.client;

  String? get currentRefreshToken => _client.auth.currentSession?.refreshToken;

  Future<RegisteredAccount?> authenticate(
    String identifier,
    String password,
  ) async {
    final value = identifier.trim();
    if (!value.contains('@')) return null;
    final response = await _client.auth.signInWithPassword(
      email: value.toLowerCase(),
      password: password,
    );
    if (response.user == null) return null;
    final account = await loadCurrentAccount();
    if (account == null) {
      throw const AuthRegistrationException(
        'The account profile could not be loaded.',
      );
    }
    return account;
  }

  Future<RegisteredAccount> register(
    SignUpAccountData data,
    AuthRole role, {
    Map<String, Object?>? riderApplication,
  }) async {
    // A Rider application is held in Auth metadata until the email OTP is
    // verified. It is written to the application database only afterwards.
    final metadata = role == AuthRole.rider
        ? <String, dynamic>{
            'requested_role': role.value,
            if (riderApplication != null)
              'rider_application': <String, dynamic>{
                for (final entry in riderApplication.entries)
                  entry.key: entry.value,
              },
          }
        : <String, Object?>{
            'first_name': data.firstName.trim(),
            'middle_name': data.middleName?.trim(),
            'last_name': data.lastName.trim(),
            'extension_name': data.extensionName?.trim(),
            'phone_number': data.phoneNumber == null
                ? null
                : PhilippinePhoneNumber.normalize(data.phoneNumber!) ??
                      data.phoneNumber!.trim(),
            'date_of_birth': data.dateOfBirth?.trim(),
            'gender': data.gender?.trim(),
            'shipping_address': data.shippingAddress?.trim(),
            'requested_role': role.value,
          };
    final response = await _client.auth.signUp(
      email: data.email.trim().toLowerCase(),
      password: data.password,
      data: metadata,
    );
    if (response.user == null) {
      throw const AuthRegistrationException('Account creation failed.');
    }
    if (response.user!.identities?.isEmpty == true) {
      throw const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    }
    if (response.session == null) {
      throw const AuthEmailConfirmationRequired();
    }
    if (role != AuthRole.rider) {
      await _client.rpc<void>(
        'provision_current_user_role',
        params: {'requested_role': role.value},
      );
    }
    final account = await loadCurrentAccount();
    if (account == null) {
      throw const AuthRegistrationException(
        'The account was created but its profile could not be loaded.',
      );
    }
    return account;
  }

  Future<RegisteredAccount?> loadCurrentAccount() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;
    final farmer = await _client
        .from('farmers')
        .select(
          'first_name,last_name,suffix,phone_number,date_of_birth,'
          'account_status,verification_status,profile_image_url',
        )
        .eq('auth_user_id', authUser.id)
        .maybeSingle();
    if (farmer != null) {
      return RegisteredAccount(
        id: authUser.id,
        firstName: _text(farmer['first_name']),
        lastName: _text(farmer['last_name']),
        email: (authUser.email ?? '').trim().toLowerCase(),
        passwordHash: '',
        passwordSalt: '',
        role: AuthRole.farmer.value,
        accountStatus: _text(farmer['account_status'], fallback: 'active'),
        extensionName: _nullableText(farmer['suffix']),
        phoneNumber: _nullableText(farmer['phone_number']),
        dateOfBirth: _nullableText(farmer['date_of_birth']),
        verificationStatus: _nullableText(farmer['verification_status']),
        profileImageUrl: _nullableText(farmer['profile_image_url']),
      );
    }
    final databaseRole = await _roleFor();
    final role = databaseRole.isEmpty ? _requestedRole(authUser) : databaseRole;
    if (role == AuthRole.rider.value) {
      final rider = await _client
          .from('riders')
          .select(
            'first_name,last_name,email,contact_number,employment_status,'
            'profile_photo_url',
          )
          .maybeSingle();
      if (rider != null) {
        return _withRiderProfileImage(_riderAccount(authUser, role, rider));
      }
      final pendingApplication = authUser.userMetadata?['rider_application'];
      if (pendingApplication is Map) {
        final rider = await _client.rpc<Object?>(
          'create_current_rider_registration',
          params: {
            'rider_payload': <String, Object?>{
              for (final entry in pendingApplication.entries)
                '${entry.key}': entry.value,
            },
          },
        );
        if (rider is Map) {
          return _withRiderProfileImage(_riderAccount(authUser, role, rider));
        }
      }
      return RegisteredAccount(
        id: authUser.id,
        firstName: '',
        lastName: '',
        email: (authUser.email ?? '').trim().toLowerCase(),
        passwordHash: '',
        passwordSalt: '',
        role: role,
        accountStatus: 'pending',
        verificationStatus: 'pending',
      );
    }
    final shipping = role == AuthRole.buyer.value
        ? await BuyerShippingAddressRepository(_client).load()
        : null;
    final row = await _client
        .from('users')
        .select(
          'first_name,last_name,extension_name,email,contact_number,'
          'date_of_birth,account_status,profile_photo_url',
        )
        .single();
    return RegisteredAccount(
      id: authUser.id,
      firstName: _text(row['first_name']),
      lastName: _text(row['last_name']),
      email: _text(row['email']).toLowerCase(),
      passwordHash: '',
      passwordSalt: '',
      role: role,
      accountStatus: _text(row['account_status'], fallback: 'unknown'),
      extensionName: _nullableText(row['extension_name']),
      phoneNumber: _nullableText(row['contact_number']),
      dateOfBirth: _nullableText(row['date_of_birth']),
      shippingAddress: shipping?.address,
      shippingLatitude: shipping?.latitude,
      shippingLongitude: shipping?.longitude,
      profileImageUrl: _nullableText(row['profile_photo_url']),
    );
  }

  Future<RegisteredAccount?> restoreSession(String refreshToken) async {
    final response = await _client.auth.setSession(refreshToken);
    if (response.user == null) return null;
    return loadCurrentAccount();
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: currentPassword,
    );
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<RegisteredAccount> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedOtp = otp.trim();
    if (!RegExp(r'^\d{6}$').hasMatch(normalizedOtp)) {
      throw const AuthOtpException(
        'That OTP is invalid. Enter the 6 digits from your email.',
        reason: AuthOtpFailureReason.invalid,
      );
    }
    final response = await _client.auth.verifyOTP(
      email: normalizedEmail,
      token: normalizedOtp,
      type: OtpType.email,
    );
    if (response.session == null || response.user?.emailConfirmedAt == null) {
      throw const AuthRegistrationException(
        'The email could not be confirmed. Request a new OTP and try again.',
      );
    }
    final account = await loadCurrentAccount();
    if (account == null) {
      throw const AuthRegistrationException(
        'Your email was verified, but the account could not be completed.',
      );
    }
    return account;
  }

  Future<void> resendSignupEmailOtp(String email) => _client.auth.resend(
    type: OtpType.signup,
    email: email.trim().toLowerCase(),
  );

  Future<void> requestPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim().toLowerCase());

  Future<void> verifyPasswordRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email.trim().toLowerCase(),
      token: otp.trim(),
      type: OtpType.recovery,
    );
    if (response.session == null) {
      throw const AuthRegistrationException(
        'The password-reset OTP is invalid or expired.',
      );
    }
  }

  Future<void> updatePasswordAfterRecovery(String password) =>
      _client.auth.updateUser(UserAttributes(password: password));

  Future<void> resendPasswordRecoveryOtp(String email) => _client.auth.resend(
    type: OtpType.recovery,
    email: email.trim().toLowerCase(),
  );

  Future<BuyerShippingAddress> saveBuyerShippingAddress(
    BuyerShippingAddress address,
  ) => BuyerShippingAddressRepository(_client).save(address);

  Future<String> _roleFor() async =>
      (await _client.rpc<Object?>(
        'current_application_role',
      ))?.toString().trim() ??
      '';

  String _requestedRole(User authUser) {
    final requested = authUser.userMetadata?['requested_role']
        ?.toString()
        .trim()
        .toLowerCase();
    return AuthRole.fromValue(requested ?? '')?.value ?? '';
  }

  String _text(Object? value, {String fallback = ''}) =>
      _nullableText(value) ?? fallback;

  String? _nullableText(Object? value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  RegisteredAccount _riderAccount(User authUser, String role, Map rider) {
    final employmentStatus = _nullableText(rider['employment_status']);
    return RegisteredAccount(
      id: authUser.id,
      firstName: _text(rider['first_name']),
      lastName: _text(rider['last_name']),
      email: _text(rider['email']).toLowerCase(),
      passwordHash: '',
      passwordSalt: '',
      role: role,
      accountStatus: employmentStatus == 'active' ? 'active' : 'pending',
      phoneNumber: _nullableText(rider['contact_number']),
      verificationStatus: employmentStatus == 'active'
          ? 'verified'
          : employmentStatus == 'suspended'
          ? 'suspended'
          : 'pending',
      profileImageUrl: _nullableText(rider['profile_photo_url']),
    );
  }

  Future<RegisteredAccount> _withRiderProfileImage(
    RegisteredAccount account,
  ) async {
    final path = account.profileImageUrl;
    if (path == null || Uri.tryParse(path)?.hasScheme == true) return account;
    try {
      final signedUrl = await _client.storage
          .from('rider-documents')
          .createSignedUrl(path, 3600);
      return account.copyWith(profileImageUrl: signedUrl);
    } on Object {
      return account.copyWith(profileImageUrl: null);
    }
  }
}
