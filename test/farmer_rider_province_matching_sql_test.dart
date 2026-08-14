import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'eligible rider lookup falls back to province and ranks municipality first',
    () {
      final sql = File(
        'supabase/migrations/'
        '20260803150000_expand_rider_matching_to_province.sql',
      ).readAsStringSync();

      expect(sql, contains('rider.province'));
      expect(sql, contains('farm.province'));
      expect(sql, contains("'same_municipality', candidate.same_municipality"));
      expect(sql, contains('order by candidate.same_municipality desc'));
    },
  );
}
