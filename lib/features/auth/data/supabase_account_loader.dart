import 'package:agresell_app/core/services/authenticated_storage_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/query_owner.dart';

import 'package:agresell_app/features/auth/data/buyer_shipping_address_repository.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

part 'supabase_account_mapping.dart';

/// Loads and maps current account profiles from Supabase across different roles.
class SupabaseAccountLoader {
  const SupabaseAccountLoader(this._client);

  final SupabaseClient _client;

  Future<RegisteredAccount?> load() async {
    final account = await _load();
    if (account == null ||
        account.assignedRole == null ||
        (!account.isActive && account.status != AuthAccountStatus.pending)) {
      return account;
    }
    if (account.profilePending) return account;
    final complete = await _client.rpc<bool>('current_signup_profile_complete');
    return account.copyWith(profilePending: !complete);
  }

  Future<RegisteredAccount?> _load() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final farmer = await _client
        .from('farmers')
        .select(
          'first_name,last_name,suffix,phone_number,date_of_birth,gender,'
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
        gender: _text(farmer['gender']),
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
      final riderId = (await QueryOwner(_client).identity())['rider_id'];
      final rider = riderId == null
          ? null
          : await _client
                .from('riders')
                .select(
                  'first_name,last_name,email,contact_number,employment_status,'
                  'profile_photo_url',
                )
                .eq('rider_id', riderId)
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
          'date_of_birth,gender,account_status,profile_photo_url',
        )
        .eq('user_id', await QueryOwner(_client).userId())
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
      gender: _text(row['gender']),
      shippingAddress: shipping?.address,
      shippingLatitude: shipping?.latitude,
      shippingLongitude: shipping?.longitude,
      profileImageUrl: _nullableText(row['profile_photo_url']),
    );
  }
}
