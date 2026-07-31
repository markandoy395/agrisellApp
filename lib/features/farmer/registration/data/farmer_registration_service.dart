import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';

class FarmerRegistrationService {
  const FarmerRegistrationService();

  static const _bucket = 'farmer-media';

  Future<RegisteredAccount> register(FarmerSignupData data) async {
    final client = AgrisellSupabase.client;
    final response = await client.auth.signUp(
      email: data.email.trim().toLowerCase(),
      password: data.password,
      data: data.toAuthMetadata(),
    );
    final user = response.user;
    if (user == null) {
      throw const AuthRegistrationException('Account creation failed.');
    }
    if (response.session == null) {
      throw const AuthEmailConfirmationRequired();
    }

    try {
      await _uploadImages(client, user.id, data);
      final farmer = await client
          .from('farmers')
          .select(
            'first_name,last_name,suffix,phone_number,date_of_birth,'
            'account_status,verification_status',
          )
          .eq('auth_user_id', user.id)
          .single();
      return RegisteredAccount(
        id: user.id,
        firstName: _text(farmer['first_name']),
        lastName: _text(farmer['last_name']),
        email: data.email.trim().toLowerCase(),
        passwordHash: '',
        passwordSalt: '',
        role: AuthRole.farmer.value,
        accountStatus: _text(farmer['account_status'], fallback: 'active'),
        extensionName: _optionalText(farmer['suffix']),
        phoneNumber: _optionalText(farmer['phone_number']),
        dateOfBirth: _optionalText(farmer['date_of_birth']),
        verificationStatus: _optionalText(farmer['verification_status']),
      );
    } on PostgrestException catch (error) {
      throw AuthRegistrationException(_databaseMessage(error));
    } on StorageException catch (_) {
      throw const AuthRegistrationException(
        'Your account was created, but an image could not be uploaded. Please log in and retry.',
      );
    }
  }

  Future<void> _uploadImages(
    SupabaseClient client,
    String authUserId,
    FarmerSignupData data,
  ) async {
    final profileImage = data.profileImage;
    if (profileImage != null) {
      final url = await _upload(
        client,
        authUserId,
        'profile.jpg',
        profileImage,
      );
      await client
          .from('farmers')
          .update({'profile_image_url': url})
          .eq('auth_user_id', authUserId);
    }
    final farmImage = data.farmImage;
    if (farmImage != null) {
      final url = await _upload(client, authUserId, 'farm.jpg', farmImage);
      final farmer = await client
          .from('farmers')
          .select('farmer_user_id')
          .eq('auth_user_id', authUserId)
          .single();
      await client
          .from('farms')
          .update({
            'farm_images': [url],
          })
          .eq('farmer_user_id', farmer['farmer_user_id'] as int);
    }
  }

  Future<String> _upload(
    SupabaseClient client,
    String authUserId,
    String filename,
    Uint8List bytes,
  ) async {
    final path = '$authUserId/$filename';
    await client.storage
        .from(_bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );
    return client.storage.from(_bucket).getPublicUrl(path);
  }
}

String _databaseMessage(PostgrestException error) => switch (error.code) {
  '23505' => 'An account with this information already exists.',
  '42501' => 'Your account could not be authorized. Please sign in again.',
  _ => 'Farmer registration could not be completed. Please try again.',
};

String _text(Object? value, {String fallback = ''}) =>
    _optionalText(value) ?? fallback;

String? _optionalText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
