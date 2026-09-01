import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('map RPCs expose invoker wrappers over private implementations', () {
    final sql = File(
      'supabase/migrations/'
      '20260819103000_harden_rider_map_discovery_rpcs.sql',
    ).readAsStringSync().toLowerCase();

    for (final rpc in [
      'current_rider_nearby_deliveries',
      'current_rider_nearby_farms',
    ]) {
      expect(sql, contains('rename to api_impl_$rpc'));
      expect(
        sql,
        contains('alter function public.api_impl_$rpc('),
      );
      expect(sql, contains('private.api_impl_$rpc('));
      expect(sql, contains('create function public.$rpc('));
    }

    expect(RegExp(r'security invoker').allMatches(sql), hasLength(2));
    expect(
      sql,
      contains(
        'from public, anon, authenticated, service_role',
      ),
    );
    expect(
      sql,
      contains('to authenticated, service_role'),
    );
    expect(sql, contains("notify pgrst, 'reload schema'"));
  });
}
