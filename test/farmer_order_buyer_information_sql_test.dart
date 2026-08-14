import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260811140000_add_farmer_order_buyer_information.sql',
    ).readAsStringSync();
  });

  test(
    'captures buyer name while reusing order address and phone snapshots',
    () {
      expect(sql, contains('buyer_name_snapshot'));
      expect(sql, contains('before insert on public.orders'));
      expect(sql, contains('order_record.delivery_address'));
      expect(sql, contains('order_record.contact_number'));
      expect(sql, isNot(contains('add column if not exists delivery_address')));
      expect(sql, isNot(contains('add column if not exists contact_number')));
    },
  );

  test(
    'seller order snapshot includes stable identity and buyer relationship',
    () {
      expect(sql, contains("'buyerId', buyer_id"));
      expect(sql, contains("'buyerName', buyer_name"));
      expect(sql, contains('cart.buyer_user_id'));
      expect(sql, contains('order_record.buyer_name_snapshot'));
    },
  );

  test('buyer details remain scoped to the authenticated farmer farms', () {
    expect(sql, contains('where identity.auth_user_id = (select auth.uid())'));
    expect(sql, contains('on identity.farmer_user_id = farm.farmer_user_id'));
    expect(
      sql,
      isNot(contains('grant select on public.users to authenticated')),
    );
    expect(
      sql,
      contains(
        'revoke all on function private.capture_order_buyer_name_snapshot()\n'
        '  from public, anon, authenticated',
      ),
    );
  });
}
