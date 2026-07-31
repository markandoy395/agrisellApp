import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260729110000_add_marketplace_messaging.sql',
    ).readAsStringSync().toLowerCase();
  });

  test('messaging tables enforce participant row-level reads', () {
    expect(
      sql,
      contains(
        'alter table public.marketplace_conversations enable row level security',
      ),
    );
    expect(
      sql,
      contains(
        'alter table public.marketplace_messages enable row level security',
      ),
    );
    expect(sql, contains('marketplace_conversations_participant_read'));
    expect(sql, contains('marketplace_messages_participant_read'));
    expect(
      sql,
      contains('revoke all on public.marketplace_messages from public, anon'),
    );
  });

  test('send role is derived from the target conversation participant', () {
    expect(sql, contains('actor_is_buyer boolean'));
    expect(sql, contains('actor_is_farmer boolean'));
    expect(
      sql,
      contains('conversation.buyer_user_id = private.current_buyer_user_id()'),
    );
    expect(
      sql,
      contains(
        'conversation.farmer_user_id = private.current_farmer_user_id()',
      ),
    );
    expect(sql, contains('messaging identity is ambiguous or unavailable'));
  });

  test('conversation context is validated against buyer, farm, and order', () {
    expect(sql, contains('marketplace_conversations_validate_context'));
    expect(sql, contains('cart.buyer_user_id = new.buyer_user_id'));
    expect(sql, contains('commodity.farm_id = new.farm_id'));
    expect(sql, contains('conversation order context is invalid'));
  });
}
