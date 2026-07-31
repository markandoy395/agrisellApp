import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  test('controller loads, opens, and acknowledges a conversation', () async {
    final repository = FakeMarketplaceMessagingRepository();
    final controller = MarketplaceMessagingController(
      repository: repository,
      actorRole: MarketplaceActorRole.buyer,
    );

    await controller.load();
    await controller.openConversation('12');

    expect(controller.state, MarketplaceMessagingLoadState.ready);
    expect(controller.conversations.single.unreadCount, 0);
    expect(controller.messagesFor('12').single.text, 'Hello buyer');
    expect(repository.markReadCalls, 1);
  });

  test('read acknowledgement failure does not hide loaded messages', () async {
    final repository = FakeMarketplaceMessagingRepository()
      ..failMarkRead = true;
    final controller = MarketplaceMessagingController(
      repository: repository,
      actorRole: MarketplaceActorRole.buyer,
    );
    await controller.load();

    await controller.openConversation('12');

    expect(controller.messagesFor('12').single.text, 'Hello buyer');
    expect(controller.messageErrorFor('12'), isNull);
  });

  test(
    'failed optimistic message is retryable and server truth is refreshed',
    () async {
      final repository = FakeMarketplaceMessagingRepository();
      final controller = MarketplaceMessagingController(
        repository: repository,
        actorRole: MarketplaceActorRole.buyer,
      );
      await controller.load();
      await controller.openConversation('12');
      repository.failSend = true;

      final failed = await controller.sendMessage('12', 'Is this fresh?');

      expect(failed, isFalse);
      expect(
        controller.messagesFor('12').last.state,
        MarketplaceMessageState.failed,
      );
      expect(controller.conversations.single.lastMessage, 'Hello buyer');

      repository.failSend = false;
      final retried = await controller.retryMessage(
        '12',
        controller.messagesFor('12').last,
      );

      expect(retried, isTrue);
      expect(
        controller.messagesFor('12').last.state,
        MarketplaceMessageState.sent,
      );
      expect(repository.sentTexts, ['Is this fresh?', 'Is this fresh?']);
    },
  );

  test('message appears as sending while persistence is pending', () async {
    final repository = FakeMarketplaceMessagingRepository();
    final gate = Completer<MarketplaceMessage>();
    repository.sendGate = gate;
    final controller = MarketplaceMessagingController(
      repository: repository,
      actorRole: MarketplaceActorRole.buyer,
    );
    await controller.load();
    await controller.openConversation('12');

    final send = controller.sendMessage('12', 'Please reserve two kilos.');
    expect(
      controller.messagesFor('12').last.state,
      MarketplaceMessageState.sending,
    );
    gate.complete(
      MarketplaceMessage(
        id: 'saved-pending',
        senderRole: MarketplaceActorRole.buyer,
        text: 'Please reserve two kilos.',
        sentAt: DateTime.utc(2026, 7, 29, 9),
      ),
    );

    expect(await send, isTrue);
    expect(
      controller.messagesFor('12').last.state,
      MarketplaceMessageState.sent,
    );
  });

  test('background refresh cannot erase a message being sent', () async {
    final repository = FakeMarketplaceMessagingRepository(messages: {'12': []});
    final gate = Completer<MarketplaceMessage>();
    repository.sendGate = gate;
    final controller = MarketplaceMessagingController(
      repository: repository,
      actorRole: MarketplaceActorRole.buyer,
    );
    await controller.load();
    await controller.openConversation('12');

    final send = controller.sendMessage('12', 'Keep this message.');
    await controller.openConversation('12', refresh: true);
    expect(
      controller.messagesFor('12').single.state,
      MarketplaceMessageState.sending,
    );

    gate.complete(
      MarketplaceMessage(
        id: 'saved-race',
        senderRole: MarketplaceActorRole.buyer,
        text: 'Keep this message.',
        sentAt: DateTime.utc(2026, 7, 31, 10),
      ),
    );

    expect(await send, isTrue);
    expect(controller.messagesFor('12').single.text, 'Keep this message.');
    expect(
      controller.messagesFor('12').single.state,
      MarketplaceMessageState.sent,
    );
  });

  test('sending works after repository returns a fixed-length list', () async {
    final repository = _FixedLengthMessageRepository(messages: {'12': []});
    final controller = MarketplaceMessagingController(
      repository: repository,
      actorRole: MarketplaceActorRole.buyer,
    );
    await controller.load();
    await controller.openConversation('12');

    final sent = await controller.sendMessage('12', 'Now it appears.');

    expect(sent, isTrue);
    expect(controller.messagesFor('12').single.text, 'Now it appears.');
  });
}

class _FixedLengthMessageRepository extends FakeMarketplaceMessagingRepository {
  _FixedLengthMessageRepository({required super.messages});

  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) async {
    final values = await super.loadMessages(conversationId);
    return List.unmodifiable(values);
  }
}
