import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/data/rider_notification_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_notifications_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

import 'support/memory_offline_queue_repository.dart';

part 'support/rider_communication_phase11_support.dart';

void main() {
  const access = RiderConversationAccess(
    activeDeliveryIds: {'delivery-1'},
    historyDeliveryIds: {'delivery-2'},
    supportAuthorized: true,
  );

  test(
    'conversation access is limited to active, history, and support',
    () async {
      final repository = _repository(access);
      final conversations = await repository
          .watchConversations(riderId: 'rider-1')
          .first;

      expect(
        conversations.map((item) => item.id),
        containsAll(['seller', 'buyer', 'support']),
      );
      expect(conversations.map((item) => item.id), isNot(contains('other')));
      expect(
        repository.fetchMessages(riderId: 'rider-2', conversationId: 'seller'),
        throwsA(isA<RiderMessageRepositoryException>()),
      );
    },
  );

  test(
    'text, protected photo, location, read state, and unread count work',
    () async {
      final repository = _repository(access);
      final queue = RiderOfflineActionQueue(
        repository: MemoryOfflineQueueRepository(),
      );
      final controller = RiderMessagesController(
        repository: repository,
        offlineQueue: queue,
      );
      addTearDown(controller.dispose);
      addTearDown(queue.dispose);
      await controller.load(riderId: 'rider-1', access: access);
      await pumpEventQueue();
      final seller = controller.conversations.firstWhere(
        (item) => item.id == 'seller',
      );
      expect(seller.unreadCount, 2);
      await controller.selectConversation(seller);
      await pumpEventQueue();
      expect(controller.messages.first.status, RiderMessageDeliveryStatus.read);
      expect(await controller.send('I am on the way.'), isTrue);
      expect(await controller.sendPhoto('protected://chat/photo-1'), isTrue);
      expect(
        await controller.sendLocation('protected://chat/location-1'),
        isTrue,
      );
      expect(controller.messages.last.status, RiderMessageDeliveryStatus.sent);
      expect(
        controller.conversations
            .firstWhere((item) => item.id == 'seller')
            .unreadCount,
        0,
      );
      expect(
        repository.sendMessage(
          riderId: 'rider-1',
          draft: const RiderMessageDraft(
            conversationId: 'seller',
            kind: RiderMessageKind.photo,
            attachmentReference: 'https://public.example/photo.jpg',
          ),
        ),
        throwsA(isA<RiderMessageRepositoryException>()),
      );
    },
  );

  test(
    'offline message is queued, restored, synchronized, and deduplicated',
    () async {
      final repository = _repository(access);
      final queue = RiderOfflineActionQueue(
        repository: MemoryOfflineQueueRepository(),
      );
      final controller = RiderMessagesController(
        repository: repository,
        offlineQueue: queue,
      );
      addTearDown(controller.dispose);
      addTearDown(queue.dispose);
      await controller.load(riderId: 'rider-1', access: access);
      await pumpEventQueue();
      await controller.selectConversation(controller.conversations.first);
      controller.setBackendReachable(false);
      expect(await controller.send('Offline update'), isTrue);
      expect(
        await controller.sendPhoto('local-secure://chat/offline-photo'),
        isTrue,
      );
      expect(
        await controller.sendLocation('local-secure://chat/offline-location'),
        isTrue,
      );
      expect(controller.messages.last.isPending, isTrue);
      expect(queue.actions, hasLength(3));
      controller.setBackendReachable(true);
      await controller.synchronizePendingMessages();
      expect(queue.actions, isEmpty);
      expect(
        controller.messages.where((item) => item.body == 'Offline update'),
        hasLength(1),
      );
      expect(
        controller.messages.where(
          (item) => item.kind == RiderMessageKind.photo,
        ),
        hasLength(1),
      );
      expect(
        controller.messages.where(
          (item) => item.kind == RiderMessageKind.location,
        ),
        hasLength(1),
      );
    },
  );

  _registerRetryTest(access);

  test(
    'notifications deduplicate, update unread state, and deep-link',
    () async {
      final repository = InMemoryRiderNotificationRepository(
        notifications: _notifications(),
      );
      final controller = RiderNotificationsController(repository: repository);
      addTearDown(controller.dispose);
      await controller.load(riderId: 'rider-1');
      await pumpEventQueue();
      expect(controller.notifications, hasLength(2));
      expect(controller.unreadCount, 2);
      final message = controller.notifications.firstWhere(
        (item) => item.conversationId != null,
      );
      expect(
        RiderNotificationAction.fromNotification(message).destination,
        RiderNotificationDestination.conversation,
      );
      final safety = controller.notifications.firstWhere(
        (item) => item.reportId != null,
      );
      expect(
        RiderNotificationAction.fromNotification(safety).destination,
        RiderNotificationDestination.report,
      );
      await controller.markRead(message.id);
      expect(controller.unreadCount, 1);
      expect(await controller.markAllRead(), isTrue);
      expect(controller.unreadCount, 0);
      expect(await controller.delete(message.id), isTrue);
    },
  );
}
