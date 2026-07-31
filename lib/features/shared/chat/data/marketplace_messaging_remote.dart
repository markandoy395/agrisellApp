import 'package:supabase_flutter/supabase_flutter.dart';

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
    return client.rpc<Object?>(
      function,
      params: parameters.isEmpty ? null : parameters,
    );
  }
}
