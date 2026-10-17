import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/services/gateway_rpc.dart';

/// Chat mutations always use the gateway so failed attempts are counted too.
abstract final class ChatRpc {
  static Future<Object?> call(
    SupabaseClient client,
    String function,
    Map<String, Object?> parameters,
  ) => GatewayRpc.call(
    client,
    function,
    parameters,
    unavailableMessage: 'Chat is temporarily unavailable.',
  );
}
