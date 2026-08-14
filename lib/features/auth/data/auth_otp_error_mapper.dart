import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

class AuthOtpErrorMapper {
  const AuthOtpErrorMapper._();

  static AuthOtpException verification(AuthException error) {
    final code = _normalizedCode(error);
    final message = error.message.toLowerCase();
    if (_isRateLimited(error, code)) {
      return const AuthOtpException(
        'Too many OTP attempts. Wait before trying again or request a new code.',
        reason: AuthOtpFailureReason.tooManyAttempts,
      );
    }
    if (message.contains('already confirmed') ||
        message.contains('already verified')) {
      return const AuthOtpException(
        'This email is already verified. Log in to continue.',
        reason: AuthOtpFailureReason.alreadyVerified,
      );
    }
    if (code == 'otp_expired' || message.contains('expired')) {
      return const AuthOtpException(
        'That OTP has expired. Request a new code.',
        reason: AuthOtpFailureReason.expired,
      );
    }
    if (message.contains('invalid') ||
        message.contains('token') ||
        code == 'validation_failed') {
      return const AuthOtpException(
        'That OTP is invalid. Check the 6 digits and try again.',
        reason: AuthOtpFailureReason.invalid,
      );
    }
    return const AuthOtpException(
      'We could not verify the email OTP. Please try again.',
      reason: AuthOtpFailureReason.unavailable,
    );
  }

  static AuthOtpException delivery(AuthException error) {
    final code = _normalizedCode(error);
    final message = error.message.toLowerCase();
    if (_isRateLimited(error, code)) {
      return const AuthOtpException(
        'A code was requested too recently. Wait before requesting another.',
        reason: AuthOtpFailureReason.tooManyAttempts,
      );
    }
    if (code == 'email_exists' ||
        code == 'user_already_exists' ||
        message.contains('already confirmed') ||
        message.contains('already verified')) {
      return const AuthOtpException(
        'This email is already verified. Log in to continue.',
        reason: AuthOtpFailureReason.alreadyVerified,
      );
    }
    return const AuthOtpException(
      "We couldn't send the email OTP. Check the address and try again.",
      reason: AuthOtpFailureReason.deliveryFailed,
    );
  }

  static AuthRegistrationException signUp(AuthException error) {
    final code = _normalizedCode(error);
    final message = error.message.toLowerCase();
    if (_isRateLimited(error, code)) return delivery(error);
    if (code == 'email_exists' ||
        code == 'user_already_exists' ||
        message.contains('already registered')) {
      return const AuthRegistrationException(
        'This email is already registered. Log in or use another email.',
      );
    }
    if (code == 'email_address_invalid' || message.contains('invalid email')) {
      return const AuthRegistrationException('Enter a valid email address.');
    }
    if (code == 'signup_disabled') {
      return const AuthRegistrationException(
        'New account registration is temporarily unavailable.',
      );
    }
    return delivery(error);
  }

  static bool _isRateLimited(AuthException error, String code) =>
      error.statusCode == '429' ||
      code == 'over_request_rate_limit' ||
      code == 'over_email_send_rate_limit';

  static String _normalizedCode(AuthException error) =>
      error.code?.trim().toLowerCase() ?? '';
}
