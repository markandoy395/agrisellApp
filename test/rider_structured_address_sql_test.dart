import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rider structured address migration adds writable address fields', () {
    final sql = File(
      'supabase/migrations/20260803102000_add_rider_structured_address.sql',
    ).readAsStringSync();
    for (final column in [
      'address_line',
      'barangay',
      'city_municipality',
      'province',
      'postal_code',
    ]) {
      expect(sql, contains(column));
    }
    expect(sql, contains('grant update'));
  });
}
