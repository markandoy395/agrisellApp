import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/profile/data/farmer_farm_service.dart';

void main() {
  test('farm updates require the authenticated farmer to own the farm', () {
    final sql = File(
      'supabase/migrations/20260803104000_fix_farmer_owner_identity.sql',
    ).readAsStringSync();

    expect(sql, contains('create policy farms_owner_update'));
    expect(
      sql,
      contains(
        'farmer_user_id = private.current_authenticated_farmer_user_id()',
      ),
    );
    expect(sql, contains('with check'));
  });

  test('farm edit query scopes the update to its owner', () {
    final source = File(
      'lib/features/farmer/profile/data/farmer_farm_service.dart',
    ).readAsStringSync();

    expect(source, contains(".eq('farmer_user_id', owner.farmerId)"));
  });

  test('farm edits cannot overwrite the protected owner column', () {
    const draft = FarmEditDraft(
      name: 'Mark Farm',
      location: 'Purok 5',
      barangay: 'Remedios',
      cityMunicipality: 'Esperanza',
      province: 'Agusan del Sur',
      latitude: 8.68,
      longitude: 125.64,
      size: 122,
      farmingType: 'Hydroponic farming',
      irrigationType: null,
      mainCrops: ['bason'],
    );

    expect(draft.toDatabase(), isNot(contains('farmer_user_id')));
    expect(draft.toDatabase(ownerId: 42)['farmer_user_id'], 42);
  });
}
