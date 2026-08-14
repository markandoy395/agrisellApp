import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/auth/data/auth_otp_error_mapper.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

void main() {
  test('maps invalid and expired OTP failures to distinct messages', () {
    const invalid = AuthException(
      'Token is invalid',
      statusCode: '403',
      code: 'validation_failed',
    );
    const expired = AuthException(
      'Token has expired',
      statusCode: '403',
      code: 'otp_expired',
    );

    expect(
      AuthOtpErrorMapper.verification(invalid).reason,
      AuthOtpFailureReason.invalid,
    );
    expect(
      AuthOtpErrorMapper.verification(expired).reason,
      AuthOtpFailureReason.expired,
    );
  });

  test('maps verification and resend rate limits without server details', () {
    const limited = AuthException(
      'rate limit exceeded',
      statusCode: '429',
      code: 'over_request_rate_limit',
    );

    expect(
      AuthOtpErrorMapper.verification(limited).reason,
      AuthOtpFailureReason.tooManyAttempts,
    );
    expect(
      AuthOtpErrorMapper.delivery(limited).reason,
      AuthOtpFailureReason.tooManyAttempts,
    );
  });

  test('maps failed delivery and already verified email safely', () {
    const delivery = AuthException('SMTP rejected the request');
    const verified = AuthException(
      'User already confirmed',
      statusCode: '400',
      code: 'user_already_exists',
    );

    expect(
      AuthOtpErrorMapper.delivery(delivery).reason,
      AuthOtpFailureReason.deliveryFailed,
    );
    expect(
      AuthOtpErrorMapper.delivery(verified).reason,
      AuthOtpFailureReason.alreadyVerified,
    );
  });
}
