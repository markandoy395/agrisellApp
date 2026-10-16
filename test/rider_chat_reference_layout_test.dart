import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_chat_panel.dart';
import 'package:agresell_app/features/rider/chat/presentation/widgets/rider_conversation_header.dart';
import 'package:agresell_app/features/shared/chat/presentation/widgets/chat_profile_intro.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'support/memory_offline_queue_repository.dart';

void main() {
  for (final width in [320.0, 430.0]) {
    testWidgets('rider profile and shortcuts work at width $width', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(width, 740));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const access = RiderConversationAccess(activeDeliveryIds: {'delivery-1'});
      const conversation = RiderConversation(
        id: 'chat-1',
        participantLabel: 'Alex Buyer',
        party: RiderConversationParty.buyer,
        deliveryId: 'delivery-1',
        riderId: 'rider-1',
      );
      final queue = RiderOfflineActionQueue(
        repository: MemoryOfflineQueueRepository(),
      );
      final controller = RiderMessagesController(
        offlineQueue: queue,
        repository: InMemoryRiderMessageRepository(
          access: access,
          conversations: [conversation],
        ),
      );
      addTearDown(controller.dispose);
      addTearDown(queue.dispose);
      await controller.load(riderId: 'rider-1', access: access);
      await controller.selectConversation(conversation);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RiderConversationPanel(
              controller: controller,
              quickReplies: const [],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ChatProfileIntro), findsOneWidget);
      await tester.tap(find.text("I'm outside"));
      await tester.pumpAndSettle();
      expect(controller.messages.last.body, "I'm outside.");
      expect(find.byType(ChatProfileIntro), findsNothing);
      expect(
        tester
            .widget<RiderConversationHeader>(
              find.byType(RiderConversationHeader),
            )
            .conversation
            .id,
        conversation.id,
      );
      {
        await tester.tap(find.byTooltip('Conversation options'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Safety and support'));
        await tester.pumpAndSettle();
        expect(find.text('Safety & Emergency Support'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
