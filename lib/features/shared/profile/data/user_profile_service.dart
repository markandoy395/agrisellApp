import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/core/services/query_owner.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';

part 'user_profile_mapping.dart';

class UserProfileSaveException implements Exception {
  const UserProfileSaveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  Future<UserProfile> save(UserProfile profile) async {
    if (!AgrisellSupabase.isInitialized) return profile;

    final birthDate = ProfileBirthDate.parse(profile.dateOfBirth);
    final normalizedPhone = PhilippinePhoneNumber.normalize(
      profile.phoneNumber,
    );
    try {
      final client = AgrisellSupabase.client;
      final account = AuthSessionService.instance.currentAccount;
      if (account?.assignedRole?.value == 'farmer') {
        return _saveFarmerProfile(client, profile, birthDate, normalizedPhone);
      }
      final currentUser = await client
          .from('users')
          .select('user_id')
          .eq('user_id', await QueryOwner(client).userId())
          .single()
          .timeout(const Duration(seconds: 30));
      final row = await client
          .from('users')
          .update({
            'first_name': profile.firstName.trim(),
            'last_name': profile.lastName.trim(),
            'extension_name': _blankToNull(profile.extensionName),
            'contact_number': normalizedPhone,
            'date_of_birth': _databaseDate(birthDate),
          })
          .eq('user_id', currentUser['user_id'] as Object)
          .select(
            'first_name,last_name,extension_name,email,contact_number,'
            'date_of_birth',
          )
          .single()
          .timeout(const Duration(seconds: 30));

      await AuthRegistrationService.instance.loadCurrentAccount();
      return _profileFromRow(profile, row);
    } on TimeoutException {
      throw const UserProfileSaveException(
        'The request timed out. Check your connection and retry.',
      );
    } on SocketException {
      throw const UserProfileSaveException(
        'No network connection. Reconnect and retry.',
      );
    } on AuthException {
      throw const UserProfileSaveException(
        'Your session is unavailable. Please log in again.',
      );
    } on PostgrestException catch (error) {
      debugPrint(
        'User profile save failed (${error.code ?? 'unknown'}): '
        '${error.message}',
      );
      throw UserProfileSaveException(_databaseMessage(error));
    } on UserProfileSaveException {
      rethrow;
    } on Exception {
      throw const UserProfileSaveException(
        'Your profile could not be saved. Please retry.',
      );
    }
  }

  Future<UserProfile> _saveFarmerProfile(
    SupabaseClient client,
    UserProfile profile,
    ProfileBirthDate birthDate,
    String? normalizedPhone,
  ) async {
    final authUserId = client.auth.currentUser?.id;
    if (authUserId == null) {
      throw const UserProfileSaveException(
        'Your session is unavailable. Please log in again.',
      );
    }
    final row = await client
        .from('farmers')
        .update({
          'first_name': profile.firstName.trim(),
          'last_name': profile.lastName.trim(),
          'suffix': _blankToNull(profile.extensionName),
          'phone_number': normalizedPhone,
          'date_of_birth': _databaseDate(birthDate),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('auth_user_id', authUserId)
        .select('first_name,last_name,suffix,phone_number,date_of_birth')
        .single()
        .timeout(const Duration(seconds: 30));
    await AuthRegistrationService.instance.loadCurrentAccount();
    return _profileFromFarmerRow(profile, row);
  }
}
