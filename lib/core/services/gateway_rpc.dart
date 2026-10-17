import 'package:supabase_flutter/supabase_flutter.dart';

/// Preserves the caller JWT and quota errors through the protected API gateway.
abstract final class GatewayRpc {
  static Future<Object?> call(
    SupabaseClient client,
    String function,
    Map<String, Object?> parameters, {
    String unavailableMessage = 'This action is temporarily unavailable.',
  }) async {
    try {
      final response = await client.functions.invoke(
        'application-api/rest/rpc/$function',
        body: parameters,
      );
      return response.data;
    } on FunctionException catch (error) {
      final details = error.details;
      throw PostgrestException(
        code: details is Map
            ? details['code']?.toString() ?? '${error.status}'
            : '${error.status}',
        message: details is Map
            ? (details['message'] ?? details['error'] ?? unavailableMessage)
                  .toString()
            : unavailableMessage,
      );
    }
  }
}
