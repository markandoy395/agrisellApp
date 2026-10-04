import 'package:supabase_flutter/supabase_flutter.dart';

/// Resolve application IDs from the authenticated caller, never from form data.
class QueryOwner {
  const QueryOwner(this.client);
  final SupabaseClient client;

  String get authId {
    final user = client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      throw const AuthException('Please log in to access your data.');
    }
    return user.id;
  }

  void requireAuthId(String requestedId) {
    if (requestedId != authId) {
      throw const AuthException('You cannot access another account.');
    }
  }

  Future<Map<String, dynamic>> identity() async {
    final caller = authId;
    final value = await client.rpc<Object?>('current_query_owner');
    if (caller != authId || value is! Map || value['auth_user_id'] != caller) {
      throw const AuthException('Your account identity could not be verified.');
    }
    return Map<String, dynamic>.from(value);
  }

  Future<Object> userId() => _id('user_id');
  Future<Object> buyerId() => _id('buyer_user_id');

  Future<String> riderId() async => (await _id('rider_id')).toString();

  Future<void> requireRiderId(String? requestedId) async {
    if (requestedId != await riderId()) {
      throw const AuthException('You cannot access another rider account.');
    }
  }

  Future<void> requireStoragePath(String path) async {
    if (path.split('/').first != authId || path.split('/').contains('..')) {
      throw const AuthException('You cannot access another account’s files.');
    }
  }

  Future<Object> _id(String key) async {
    final value = (await identity())[key];
    if (value == null) throw const AuthException('Account profile not found.');
    return value as Object;
  }
}
