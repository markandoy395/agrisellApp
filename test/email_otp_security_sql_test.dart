import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('local email OTP length matches the six-digit Flutter input', () {
    final config = File('supabase/config.toml').readAsStringSync();
    final emailSection = config
        .split('[auth.email]')
        .last
        .split('[auth.sms]')
        .first;

    expect(emailSection, contains('otp_length = 6'));
  });

  test('role RPCs require a server-confirmed email', () {
    final sql = File(
      'supabase/migrations/20260813120000_require_verified_email_for_role_access.sql',
    ).readAsStringSync();

    expect(sql, contains('auth_user.email_confirmed_at is not null'));
    expect(sql, contains('private.current_email_is_verified()'));
    expect(sql, contains("raise exception 'Email verification is required'"));
    expect(
      sql,
      contains('revoke all on function public.provision_current_user_role'),
    );
    expect(
      sql,
      contains(
        'revoke all on function public.create_current_rider_registration',
      ),
    );
  });

  test('credentials-first profiles are staged behind verified RPCs', () {
    final sql = File(
      'supabase/migrations/20260816120000_stage_credentials_before_signup_profiles.sql',
    ).readAsStringSync();

    expect(sql, contains("signup_stage = 'profile_pending'"));
    expect(sql, contains("requested_role in ('buyer', 'farmer', 'rider')"));
    expect(sql, contains('private.current_email_is_verified()'));
    expect(sql, contains('complete_current_buyer_registration'));
    expect(sql, contains('complete_current_farmer_registration'));
    expect(
      sql,
      contains(
        'grant execute on function public.complete_current_farmer_registration',
      ),
    );
  });
}
