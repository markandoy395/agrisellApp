import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_remote.dart';
import 'package:agresell_app/features/shared/chat/data/supabase_marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

void main() {
  test(
    'repository decodes scoped conversation and message RPC results',
    () async {
      final remote = _FakeRemote({
        'current_marketplace_conversations': [
          {
            'conversation_id': '12',
            'buyer_name': 'Alex Buyer',
            'farmer_name': 'Maria Santos',
            'farm_name': 'Green Farm',
            'farm_location': 'Purok 4, San Jose, La Trinidad, Benguet',
            'last_message': 'Available tomorrow',
            'last_message_at': '2026-07-29T08:00:00Z',
            'unread_count': 2,
          },
        ],
        'marketplace_conversation_messages': [
          {
            'message_id': '31',
            'sender_role': 'farmer',
            'body': 'Available tomorrow',
            'sent_at': '2026-07-29T08:00:00Z',
          },
        ],
      });
      final repository = SupabaseMarketplaceMessagingRepository.withRemote(
        remote,
      );

      final conversations = await repository.loadConversations();
      final messages = await repository.loadMessages('12');

      expect(conversations.single.farmerName, 'Maria Santos');
      expect(
        conversations.single.location,
        'Purok 4, San Jose, La Trinidad, Benguet',
      );
      expect(conversations.single.unreadCount, 2);
      expect(messages.single.senderRole, MarketplaceActorRole.farmer);
      expect(remote.calls.last.parameters, {'conversation_id': 12});
    },
  );

  test(
    'repository sends only validated context and trimmed message values',
    () async {
      final remote = _FakeRemote({
        'start_marketplace_conversation': 12,
        'send_marketplace_message': {
          'message_id': '32',
          'sender_role': 'buyer',
          'body': 'Is this fresh?',
          'sent_at': '2026-07-29T09:00:00Z',
        },
      });
      final repository = SupabaseMarketplaceMessagingRepository.withRemote(
        remote,
      );
      final id = await repository.startConversation(
        const MarketplaceConversationSeed(
          sellerName: 'Maria Santos',
          commodityId: '8',
          clientOrderId: 'ORD-100',
        ),
      );
      final message = await repository.sendMessage(
        conversationId: id,
        text: 'Is this fresh?',
      );

      expect(id, '12');
      expect(remote.calls.first.parameters, {
        'commodity_id': 8,
        'farm_id': null,
        'client_order_id': 'ORD-100',
      });
      expect(message.text, 'Is this fresh?');
      expect(remote.calls.last.parameters['conversation_id'], 12);
    },
  );
}

class _RemoteCall {
  const _RemoteCall(this.function, this.parameters);
  final String function;
  final Map<String, Object?> parameters;
}

class _FakeRemote implements MarketplaceMessagingRemote {
  _FakeRemote(this.responses);
  final Map<String, Object?> responses;
  final List<_RemoteCall> calls = [];

  @override
  Future<Object?> call(
    String function, {
    Map<String, Object?> parameters = const {},
  }) async {
    calls.add(_RemoteCall(function, parameters));
    return responses[function];
  }
}
