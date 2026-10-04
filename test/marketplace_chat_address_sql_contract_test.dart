import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sql = File(
    'supabase/migrations/20261004100000_complete_marketplace_chat_address.sql',
  ).readAsStringSync().toLowerCase();
  test(
    'conversation address uses complete farm fields behind participant guards',
    () {
      expect(
        sql,
        contains(
          'farm.farm_location, farm.barangay, farm.city_municipality, farm.province',
        ),
      );
      expect(sql, contains('conversation.buyer_user_id = actor.buyer_id'));
      expect(sql, contains('conversation.farmer_user_id = actor.farmer_id'));
      expect(sql, contains('auth.uid() is null'));
      expect(sql, contains("auth.jwt()->>'is_anonymous'"));
      expect(sql, contains("auth.jwt()->>'exp'"));
      expect(sql, contains("set search_path = ''"));
      expect(sql, contains('from public, anon'));
      expect(sql, isNot(contains('farmer.address_line')));
      expect(sql, isNot(contains('execute format')));
    },
  );
}
