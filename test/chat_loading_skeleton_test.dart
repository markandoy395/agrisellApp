import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/buyer/chat/presentation/screens/buyer_message_screen.dart';
import 'package:agresell_app/features/farmer/chat/presentation/screens/farmer_message_screen.dart';
import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_messages_inbox.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_conversation_tile.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_loading_skeleton.dart';
import 'support/marketplace_messaging_fakes.dart';
import 'support/memory_offline_queue_repository.dart';

void main() {
  for (final role in MarketplaceActorRole.values) {
    testWidgets('${role.name} inbox and thread show skeletons until loaded', (
      tester,
    ) async {
      final repository = _PendingMarketplace(role);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: role == MarketplaceActorRole.buyer
                ? BuyerMessageScreen(
                    repository: repository,
                    autoRefreshInterval: Duration.zero,
                  )
                : FarmerMessageScreen(
                    repository: repository,
                    autoRefreshInterval: Duration.zero,
                  ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('Loading conversations'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      repository.inbox.complete([marketplaceConversationFixture()]);
      await tester.pumpAndSettle();
      expect(find.byType(ChatLoadingSkeleton), findsNothing);
      await tester.tap(find.byType(ChatConversationTile));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('Loading messages'), findsOneWidget);
      repository.thread.complete([marketplaceMessageFixture()]);
      await tester.pumpAndSettle();
      expect(find.byType(ChatLoadingSkeleton), findsNothing);
      expect(find.text('Hello buyer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'rider inbox shows skeleton before its first conversation event',
    (tester) async {
      final repository = _PendingRider();
      final queue = RiderOfflineActionQueue(
        repository: MemoryOfflineQueueRepository(),
      );
      final controller = RiderMessagesController(
        repository: repository,
        offlineQueue: queue,
      );
      addTearDown(controller.dispose);
      addTearDown(queue.dispose);
      addTearDown(repository.events.close);
      await controller.load(riderId: 'rider-1');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiderMessagesInbox(
              controller: controller,
              onOpen: (_) {},
              onRetry: () => controller.load(riderId: 'rider-1'),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.bySemanticsLabel('Loading conversations'), findsOneWidget);
      expect(find.text('No delivery conversations'), findsNothing);
      repository.events.add([]);
      await tester.pumpAndSettle();
      expect(find.byType(ChatLoadingSkeleton), findsNothing);
      expect(find.text('No delivery conversations'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final width in [320.0, 430.0]) {
    for (final conversations in [true, false]) {
      testWidgets(
        'chat skeleton fits $width; inbox=$conversations; reduced motion',
        (tester) async {
          await tester.binding.setSurfaceSize(Size(width, 740));
          addTearDown(() => tester.binding.setSurfaceSize(null));
          await tester.pumpWidget(
            MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              ),
              home: Scaffold(
                body: ChatLoadingSkeleton(conversations: conversations),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.binding.hasScheduledFrame, isFalse);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

class _PendingMarketplace extends FakeMarketplaceMessagingRepository {
  _PendingMarketplace(MarketplaceActorRole role) : super(actorRole: role);
  final inbox = Completer<List<MarketplaceConversation>>();
  final thread = Completer<List<MarketplaceMessage>>();

  @override
  Future<List<MarketplaceConversation>> loadConversations() => inbox.future;

  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) =>
      thread.future;
}

class _PendingRider extends InMemoryRiderMessageRepository {
  final events = StreamController<List<RiderConversation>>();

  @override
  Stream<List<RiderConversation>> watchConversations({
    required String riderId,
  }) => events.stream;
}
