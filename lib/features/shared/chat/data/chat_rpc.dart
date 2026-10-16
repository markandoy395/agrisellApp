import 'package:supabase_flutter/supabase_flutter.dart';

/// Chat mutations always use the gateway so failed attempts are counted too.
abstract final class ChatRpc {
  static Future<Object?> call(
    SupabaseClient client,
    String function,
    Map<String, Object?> parameters,
  ) async {
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
            ? (details['message'] ??
                      details['error'] ??
                      'Chat is temporarily unavailable.')
                  .toString()
            : 'Chat is temporarily unavailable.',
      );
    }
  }
}
