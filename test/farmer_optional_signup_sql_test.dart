import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File(
    'supabase/migrations/20261017130000_optional_farmer_farm_details_and_uploads.sql',
  ).readAsStringSync();

  test('optional farm completion retains caller, role and gateway checks', () {
    expect(sql, contains('perform private.require_profile_editor()'));
    expect(sql, contains('perform public.require_rate_limited_gateway()'));
    expect(sql, contains('private.current_email_is_verified()'));
    expect(sql, contains("requested_role is distinct from 'farmer'"));
    expect(sql, contains('for update'));
    expect(sql, contains('if not skip_farm then'));
    expect(sql, contains('f.farm_details_skipped or'));
    expect(sql, contains('from public, anon'));
    expect(
      sql,
      isNot(
        contains(
          'grant execute on function public.current_signup_profile_complete() to anon',
        ),
      ),
    );
  });

  test('upload policies require active ownership and consistent category', () {
    final policies = sql.substring(sql.indexOf('-- Approval is optional'));
    expect(policies, contains("'pending', 'verified', 'needs_information'"));
    expect(policies, contains("lower(farmer.account_status) = 'active'"));
    expect(policies, contains('farmer.auth_user_id = (select auth.uid())'));
    expect(policies, contains('category.farm_id = commodities.farm_id'));
    expect(policies, contains("auth.jwt() ->> 'is_anonymous'"));
    expect(policies, isNot(contains('to anon')));
  });
}
