import 'dart:async';

import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

MarketplaceConversation marketplaceConversationFixture({
  String id = '12',
  int unreadCount = 1,
  String location = 'Benguet',
}) => MarketplaceConversation(
  id: id,
  buyerName: 'Alex Buyer',
  farmerName: 'Maria Santos',
  farmName: 'Green Farm',
  location: location,
  commodityId: '8',
  productName: 'Tomatoes',
  orderReference: 'ORD-100',
  orderStatus: 'preparing',
  quantity: 2,
  unitPrice: 75,
  unitType: 'kg',
  lastMessage: 'Hello buyer',
  updatedAt: DateTime.utc(2026, 7, 29, 8),
  unreadCount: unreadCount,
);

MarketplaceMessage marketplaceMessageFixture({
  String id = '31',
  MarketplaceActorRole role = MarketplaceActorRole.farmer,
  String text = 'Hello buyer',
}) => MarketplaceMessage(
  id: id,
  senderRole: role,
  text: text,
  sentAt: DateTime.utc(2026, 7, 29, 8),
);

class FakeMarketplaceMessagingRepository
    implements MarketplaceMessagingRepository {
  FakeMarketplaceMessagingRepository({
    this.actorRole = MarketplaceActorRole.buyer,
    List<MarketplaceConversation>? conversations,
    Map<String, List<MarketplaceMessage>>? messages,
  }) : conversations = conversations ?? [marketplaceConversationFixture()],
       messages =
           messages ??
           {
             '12': [marketplaceMessageFixture()],
           };

  final MarketplaceActorRole actorRole;
  List<MarketplaceConversation> conversations;
  final Map<String, List<MarketplaceMessage>> messages;
  final List<String> sentTexts = [];
  final List<MarketplaceConversationSeed> startCalls = [];
  int markReadCalls = 0;
  int loadCalls = 0;
  bool failLoad = false;
  bool failMarkRead = false;
  bool failSend = false;
  Completer<MarketplaceMessage>? sendGate;

  @override
  Future<List<MarketplaceConversation>> loadConversations() async {
    loadCalls++;
    if (failLoad) {
      throw const MarketplaceMessagingException('Load failed');
    }
    return List.of(conversations);
  }

  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) async =>
      List.of(messages[conversationId] ?? const []);

  @override
  Future<void> markRead(String conversationId) async {
    markReadCalls++;
    if (failMarkRead) {
      throw const MarketplaceMessagingException('Read update failed');
    }
  }

  @override
  Future<MarketplaceMessage> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    sentTexts.add(text);
    if (failSend) {
      throw const MarketplaceMessagingException('Send failed');
    }
    final gate = sendGate;
    final saved = gate == null
        ? MarketplaceMessage(
            id: 'saved-${sentTexts.length}',
            senderRole: actorRole,
            text: text,
            sentAt: DateTime.utc(2026, 7, 29, 9),
          )
        : await gate.future;
    messages.putIfAbsent(conversationId, () => []).add(saved);
    conversations = [
      for (final item in conversations)
        item.id == conversationId
            ? item.copyWith(lastMessage: text, updatedAt: saved.sentAt)
            : item,
    ];
    return saved;
  }

  @override
  Future<String> startConversation(MarketplaceConversationSeed seed) async {
    startCalls.add(seed);
    return conversations.first.id;
  }
}
