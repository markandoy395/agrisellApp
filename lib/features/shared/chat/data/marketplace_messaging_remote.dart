import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_rpc.dart';

abstract interface class MarketplaceMessagingRemote {
  Future<Object?> call(
    String function, {
    Map<String, Object?> parameters = const {},
  });
}

class SupabaseMarketplaceMessagingRemote implements MarketplaceMessagingRemote {
  const SupabaseMarketplaceMessagingRemote(this.client);

  final SupabaseClient client;

  @override
  Future<Object?> call(
    String function, {
    Map<String, Object?> parameters = const {},
  }) {
    if (function == 'send_marketplace_message' ||
        function == 'start_marketplace_conversation') {
      return ChatRpc.call(client, function, parameters);
    }
    return client.rpc<Object?>(
      function,
      params: parameters.isEmpty ? null : parameters,
    );
  }
}
