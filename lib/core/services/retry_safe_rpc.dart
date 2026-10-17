import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'pending_operation_store.dart';
import 'query_owner.dart';
import 'gateway_rpc.dart';
import '../utils/async_operation_gate.dart';

/// No automatic write retry or unprotected fallback after an uncertain result.
class RetrySafeRpc {
  static final _gate = AsyncOperationGate();

  static Future<Object?> call(
    SupabaseClient client,
    String function,
    Map<String, Object?> parameters, {
    Future<Object?> Function(Map<String, Object?>)? send,
  }) {
    final owner = QueryOwner(client).authId;
    final session = client.auth.currentSession;
    if (session == null || session.isExpired) {
      throw const AuthException('Sign in before submitting a request.');
    }
    return _gate.run((owner, function, jsonEncode(parameters)), () async {
      final store = PendingOperationStore();
      final attempt = await store.prepare(owner, function, parameters);
      final payload = {...parameters, 'p_request_key': attempt.id};
      QueryOwner(client).requireAuthId(owner);
      try {
        final value =
            await (send?.call(payload) ??
                GatewayRpc.call(client, function, payload));
        QueryOwner(client).requireAuthId(owner);
        await store.complete(attempt);
        return value;
      } on PostgrestException catch (error) {
        // Business failures roll back the mutation. Network/server failures retain identity.
        if (const {
          '22023',
          '22001',
          '42501',
          '23503',
          '23505',
          '23514',
          'PT400',
          'PT401',
          'PT403',
          'PT429',
          'PGRST202',
          '42883',
        }.contains(error.code)) {
          await store.complete(attempt);
        }
        rethrow;
      }
    });
  }
}
