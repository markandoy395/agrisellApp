import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final migration = File(
    'supabase/migrations/'
    '20260811175000_allow_independent_rider_cod_acceptance.sql',
  );

  test('COD capability is required only for company-linked Riders', () {
    final sql = migration.readAsStringSync().toLowerCase();
    final validatorSql = File(
      'supabase/migrations/'
      '20260811172000_fix_rider_acceptance_deadline_validation.sql',
    ).readAsStringSync().toLowerCase();

    expect(
      sql,
      contains('rider_record.logistics_company_id is not null'),
    );
    expect(validatorSql, contains('company.cod_available'));
    expect(sql, contains('execute patched_definition'));
  });
}
