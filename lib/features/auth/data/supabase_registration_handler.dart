import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/data/supabase_account_loader.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

/// Handles user sign-up and buyer profile completion.
class SupabaseRegistrationHandler {
  SupabaseRegistrationHandler(
    this._client, {
    SupabaseAccountLoader? accountLoader,
  }) : _accountLoader = accountLoader ?? SupabaseAccountLoader(_client);

  final SupabaseClient _client;
  final SupabaseAccountLoader _accountLoader;

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

    final account = await _accountLoader.load();
    if (account == null) {
      throw const AuthRegistrationException(
        'The account was created but its profile could not be loaded.',
      );
    }
    return account;
  }

  Future<RegisteredAccount> completeVerifiedBuyerRegistration(
    SignUpAccountData data,
  ) async {
    final user = _client.auth.currentUser;
    final email = data.email.trim().toLowerCase();
    if (user == null || user.email?.trim().toLowerCase() != email) {
      throw const AuthRegistrationException(
        'Sign in with the Buyer account before completing registration.',
      );
    }
    if (user.emailConfirmedAt == null) throw const AuthEmailNotVerified();

    await _client.rpc<void>(
      'complete_current_buyer_registration',
      params: {
        'buyer_payload': <String, Object?>{
          'first_name': data.firstName.trim(),
          'last_name': data.lastName.trim(),
          'extension_name': data.extensionName?.trim(),
          'phone_number': data.phoneNumber?.trim(),
          'date_of_birth': data.dateOfBirth?.trim(),
          'gender': data.gender?.trim(),
          'shipping_address': data.shippingAddress?.trim(),
          'accepted_policy': data.acceptedPolicy,
        },
      },
    );

    final account = await _accountLoader.load();
    if (account == null || account.assignedRole != AuthRole.buyer) {
      throw const AuthRegistrationException(
        'The Buyer account was created but its profile could not be loaded.',
      );
    }
    return account;
  }
}
