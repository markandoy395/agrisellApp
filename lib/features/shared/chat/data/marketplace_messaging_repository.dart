import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

abstract interface class MarketplaceMessagingRepository {
  Future<List<MarketplaceConversation>> loadConversations();

  Future<List<MarketplaceMessage>> loadMessages(String conversationId);

  Future<String> startConversation(MarketplaceConversationSeed seed);

  Future<MarketplaceMessage> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<void> markRead(String conversationId);
}

class EmptyMarketplaceMessagingRepository
    implements MarketplaceMessagingRepository {
  const EmptyMarketplaceMessagingRepository();

  @override
  Future<List<MarketplaceConversation>> loadConversations() async => const [];

  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) async =>
      const [];

  @override
  Future<void> markRead(String conversationId) async {}

  @override
  Future<MarketplaceMessage> sendMessage({
    required String conversationId,
    required String text,
  }) => throw const MarketplaceMessagingException(
    'Sign in to send marketplace messages.',
  );

  @override
  Future<String> startConversation(MarketplaceConversationSeed seed) =>
      throw const MarketplaceMessagingException(
        'Sign in to message this farmer.',
      );
}

class MarketplaceMessagingException implements Exception {
  const MarketplaceMessagingException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
