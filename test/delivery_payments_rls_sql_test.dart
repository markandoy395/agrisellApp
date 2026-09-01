import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delivery payments enables RLS with scoped read-only access', () {
    final sql = File(
      'supabase/migrations/'
      '20260819102500_secure_delivery_payments_rls.sql',
    ).readAsStringSync().toLowerCase();

    expect(
      sql,
      contains(
        'alter table public.delivery_payments enable row level security',
      ),
    );
    expect(sql, contains('private.is_admin()'));
    expect(sql, contains('private.rider_owns_delivery(delivery_id)'));
    expect(
      sql,
      contains(
        'revoke all privileges on table public.delivery_payments\n'
        '  from public, anon, authenticated',
      ),
    );
    expect(
      sql,
      contains(
        'grant select on table public.delivery_payments to authenticated',
      ),
    );
    expect(sql, isNot(contains('grant insert')));
    expect(sql, isNot(contains('grant update')));
    expect(sql, isNot(contains('grant delete')));
  });
}
