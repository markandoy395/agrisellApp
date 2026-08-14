import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('delivery realtime RLS keeps assignments behind a definer function', () {
    final sql = File(
      'supabase/migrations/20260803101000_fix_rider_delivery_realtime_rls.sql',
    ).readAsStringSync();

    expect(
      sql,
      contains(
        'private.can_access_delivery(\n  target_delivery_id bigint\n) returns boolean',
      ),
    );
    expect(sql, contains('security definer'));
    expect(sql, contains('using (private.can_access_delivery(delivery_id))'));
    expect(
      sql,
      isNot(
        contains(
          'create policy deliveries_access_read\n'
          'on public.deliveries for select to authenticated\n'
          'using (private.can_access_delivery(delivery_id) or',
        ),
      ),
    );
  });
}
