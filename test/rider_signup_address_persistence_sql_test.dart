import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Rider OTP registration persists every structured address field', () {
    final sql = File(
      'supabase/migrations/'
      '20260809120000_store_rider_signup_structured_address.sql',
    ).readAsStringSync();

    expect(
      sql,
      contains(
        'address_line, barangay, city_municipality, province, postal_code',
      ),
    );
    for (final field in [
      'address_line',
      'barangay',
      'city_municipality',
      'province',
      'postal_code',
    ]) {
      expect(sql, contains("rider_payload ->> '$field'"));
      expect(sql, contains('$field = coalesce('));
    }
    expect(sql, contains("raw_user_meta_data - 'rider_application'"));
  });
}
