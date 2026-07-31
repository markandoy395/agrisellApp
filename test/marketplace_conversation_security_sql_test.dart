import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/'
      '20260731110000_harden_marketplace_conversations.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('participant access is derived from the signed-in auth user', () {
    expect(sql, contains('buyer_identity.auth_user_id = (select auth.uid())'));
    expect(sql, contains('farmer.auth_user_id = (select auth.uid())'));
    expect(sql, contains('using (private.can_access_marketplace_conversation'));
  });

  test('only public, hardened RPC functions remain callable by clients', () {
    expect(sql, contains('security definer'));
    expect(
      sql,
      contains(
        'revoke all on function private.send_marketplace_message(bigint, text)',
      ),
    );
    expect(
      sql,
      contains(
        'grant execute on function public.send_marketplace_message(bigint, text)',
      ),
    );
  });
}
