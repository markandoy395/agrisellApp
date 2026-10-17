import 'package:supabase_flutter/supabase_flutter.dart';

/// New profile mutations always use the persistent server-side quota gateway.
Future<Object?> invokeProfileRpc(
  SupabaseClient client,
  String name,
  Map<String, Object?> params,
) async {
  final session = client.auth.currentSession;
  if (session == null || session.isExpired || session.user.isAnonymous) {
    throw const AuthException('Sign in before saving your profile.');
  }
  try {
    final response = await client.functions.invoke(
      'application-api/rest/rpc/$name',
      body: params,
    );
    return response.data;
  } on FunctionException catch (error) {
    throw PostgrestException(
      message: error.status == 429
          ? 'Too many requests. Please try again later.'
          : 'Your profile could not be saved. Please retry.',
      code: '${error.status}',
    );
  }
}
