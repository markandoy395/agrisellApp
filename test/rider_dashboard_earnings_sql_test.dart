import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rider dashboard exposes persisted earnings as available data', () {
    final sql = File(
      'supabase/migrations/20260803140000_connect_rider_dashboard_earnings.sql',
    ).readAsStringSync();

    expect(sql, contains("to_regclass('public.delivery_payments')"));
    expect(sql, contains("to_regclass('public.delivery_payment')"));
    expect(sql, contains('left join %s as payment'));
    expect(sql, contains("'today_estimated_earnings', earned_today"));
    expect(sql, contains("'pending_earnings', pending_earnings"));
    expect(sql, contains("'unavailable_sections', '[]'::jsonb"));
  });
}
