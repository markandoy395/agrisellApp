import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

/// Loads and maps current account profiles from Supabase across different roles.
class SupabaseAccountLoader {
  const SupabaseAccountLoader(this._client);

  final SupabaseClient _client;

  Future<RegisteredAccount?> load() async {
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

    if (databaseRole.isEmpty &&
        (role == AuthRole.buyer.value || role == AuthRole.farmer.value)) {
      return _pendingAccount(authUser, role);
    }

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

      return _pendingAccount(authUser, role);
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

  RegisteredAccount _pendingAccount(User authUser, String role) =>
      RegisteredAccount(
        id: authUser.id,
        firstName: '',
        lastName: '',
        email: (authUser.email ?? '').trim().toLowerCase(),
        passwordHash: '',
        passwordSalt: '',
        role: role,
        accountStatus: 'pending',
        verificationStatus: 'pending',
        profilePending: true,
      );

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
      final signedUrl = authenticatedStorageUrl(
        _client.storage.from('rider-documents').getPublicUrl(path),
      );
      return account.copyWith(profileImageUrl: signedUrl);
    } on Object {
      return account.copyWith(profileImageUrl: null);
    }
  }
}
