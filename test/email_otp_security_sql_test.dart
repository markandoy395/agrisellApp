import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
