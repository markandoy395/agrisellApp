import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/location/data/confirmed_location_remote_data_source.dart';
import 'package:agresell_app/features/shared/location/domain/confirmed_location.dart';

class SupabaseConfirmedLocationRemoteDataSource
    implements ConfirmedLocationRemoteDataSource {
  SupabaseConfirmedLocationRemoteDataSource(this.client)
    : _owner = client.auth.currentUser?.id;

  final SupabaseClient client;
  final String? _owner;

  static SupabaseConfirmedLocationRemoteDataSource? currentOrNull() {
    if (!AgrisellSupabase.isInitialized) return null;
    final client = AgrisellSupabase.client;
    if (client.auth.currentUser == null) return null;
    return SupabaseConfirmedLocationRemoteDataSource(client);
  }

  @override
  Future<void> save(LocationOwnerRole role, ConfirmedLocation location) async {
    final session = client.auth.currentSession;
    if (_owner == null ||
        session == null ||
        session.isExpired ||
        session.user.isAnonymous ||
        session.user.id != _owner) {
      throw const AuthException('Sign in again before saving this location.');
    }
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
