import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260811174000_fix_rider_accept_delivery_authorization.sql',
  );

  test('accept delivery can invoke its private batch validator', () {
    final sql = migration.readAsStringSync().toLowerCase();

    expect(sql, contains('function public.accept_delivery'));
    expect(sql, contains('security definer'));
    expect(sql, contains('private.validate_delivery_batch_acceptance'));
    expect(sql, contains('return private.accept_delivery'));
    expect(
      sql,
      contains(
        'grant execute on function public.accept_delivery(bigint, uuid)\n'
        '  to authenticated',
      ),
    );
    expect(
      sql,
      contains(
        'private.rider_is_eligible_for_delivery(bigint, uuid)\n'
        '  from public, anon, authenticated',
      ),
    );
  });
}
