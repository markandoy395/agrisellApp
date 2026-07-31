import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String sql;

  setUpAll(() {
    sql = File(
      'supabase/migrations/20260730131000_dispatch_fcm_notifications.sql',
    ).readAsStringSync().toLowerCase();
  });

  test(
    'notification insertion dispatches asynchronously to the Edge Function',
    () {
      expect(sql, contains('create extension if not exists pg_net'));
      expect(sql, contains('net.http_post'));
      expect(sql, contains('after insert on public.notifications'));
    },
  );

  test('function endpoint and auth secret are read from Supabase Vault', () {
    expect(sql, contains("name = 'push_function_url'"));
    expect(sql, contains("name = 'push_function_secret'"));
    expect(sql, contains('x-agrisell-webhook-secret'));
  });
}
