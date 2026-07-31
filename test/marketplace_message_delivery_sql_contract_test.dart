import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260731100000_fix_marketplace_message_delivery.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('message sender is resolved from the authenticated account', () {
    expect(sql, contains('actor_auth_id uuid := (select auth.uid())'));
    expect(
      sql,
      contains('where identity.buyer_user_id = target.buyer_user_id'),
    );
    expect(
      sql,
      contains('where farmer.farmer_user_id = target.farmer_user_id'),
    );
  });

  test('a saved message creates a recipient push notification', () {
    expect(sql, contains('insert into public.marketplace_messages'));
    expect(sql, contains('insert into public.notifications'));
    expect(sql, contains("'new_message'"));
    expect(sql, contains("'messages'"));
    expect(sql, contains("'conversation_id'"));
  });
}
