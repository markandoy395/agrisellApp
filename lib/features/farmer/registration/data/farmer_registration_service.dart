import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_otp_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';

class FarmerRegistrationService {
  const FarmerRegistrationService();

  static const _bucket = 'farmer-media';

  Future<RegisteredAccount> register(FarmerSignupData data) async {
    final client = AgrisellSupabase.client;
    final email = data.email.trim().toLowerCase();
    late final AuthResponse response;
    try {
      response = await client.auth.signUp(
        email: email,
        password: data.password,
        data: data.toAuthMetadata(),
      );
    } on AuthException catch (error) {
      throw AuthOtpErrorMapper.signUp(error);
    }
    final user = response.user;
    if (user == null) {
      throw const AuthRegistrationException('Account creation failed.');
    }
    if (user.identities?.isEmpty == true) {
      throw const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    }
    if (response.session == null) {
      throw const AuthEmailConfirmationRequired();
    }

    return completeVerifiedRegistration(data);
  }

  Future<RegisteredAccount> completeVerifiedRegistration(
    FarmerSignupData data,
  ) async {
    final client = AgrisellSupabase.client;
    final user = client.auth.currentUser;
    final email = data.email.trim().toLowerCase();
    if (user == null || user.email?.trim().toLowerCase() != email) {
      throw const AuthRegistrationException(
        'Sign in with the Farmer account before completing registration.',
      );
    }
    if (user.emailConfirmedAt == null) {
      throw const AuthEmailNotVerified();
    }

    try {
      await client.rpc<void>(
        'complete_current_farmer_registration',
        params: {'farmer_payload': data.toAuthMetadata()},
      );
      await _uploadImages(client, user.id, data);
      final farmer = await client
          .from('farmers')
          .select(
            'first_name,last_name,suffix,phone_number,date_of_birth,gender,'
            'account_status,verification_status,profile_image_url',
          )
          .eq('auth_user_id', user.id)
          .single();
      return RegisteredAccount(
        id: user.id,
        firstName: _text(farmer['first_name']),
        lastName: _text(farmer['last_name']),
        email: email,
        passwordHash: '',
        passwordSalt: '',
        role: AuthRole.farmer.value,
        accountStatus: _text(farmer['account_status'], fallback: 'active'),
        extensionName: _optionalText(farmer['suffix']),
        phoneNumber: _optionalText(farmer['phone_number']),
        dateOfBirth: _optionalText(farmer['date_of_birth']),
        gender: _text(farmer['gender']),
        verificationStatus: _optionalText(farmer['verification_status']),
        profileImageUrl: _optionalText(farmer['profile_image_url']),
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
  '23505' => _uniqueViolationMessage(error),
  '42501' => 'Your account could not be authorized. Please sign in again.',
  _ => 'Farmer registration could not be completed. Please try again.',
};

String _uniqueViolationMessage(PostgrestException error) {
  final details = '${error.message} ${error.details}'.toLowerCase();
  if (details.contains('email')) {
    return 'This email is already registered. Please log in or use another email.';
  }
  if (details.contains('phone') || details.contains('contact')) {
    return 'This phone number is already registered. Please use another phone number.';
  }
  return 'This account information is already registered.';
}

String _text(Object? value, {String fallback = ''}) =>
    _optionalText(value) ?? fallback;

String? _optionalText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
