import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

class SupabaseConfirmedLocationRemoteDataSource
    implements ConfirmedLocationRemoteDataSource {
  const SupabaseConfirmedLocationRemoteDataSource(this.client);

  final SupabaseClient client;

  static SupabaseConfirmedLocationRemoteDataSource? currentOrNull() {
    if (!AgrisellSupabase.isInitialized) return null;
    final client = AgrisellSupabase.client;
    if (client.auth.currentUser == null) return null;
    return SupabaseConfirmedLocationRemoteDataSource(client);
  }

  @override
  Future<void> save(LocationOwnerRole role, ConfirmedLocation location) async {
    await client.rpc<void>(
      'save_current_confirmed_location',
      params: {
        'owner_role': role.name,
        'address_value': location.address?.trim(),
        'latitude_value': location.latitude,
        'longitude_value': location.longitude,
      },
    );
  }
}
