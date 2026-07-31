part of '../rider_communication_phase11_test.dart';

void _registerRetryTest(RiderConversationAccess access) {
  test('failed offline message can be retried safely', () async {
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
    final action = await queue.add(
      riderId: 'rider-1',
      deliveryId: 'delivery-1',
      type: OfflineDeliveryActionType.message,
      payload: const {
        'conversationId': 'seller',
        'body': 'Retry this update',
        'kind': 'text',
      },
      originalTimestamp: DateTime(2026, 7, 15),
      idempotencyKey: 'message-retry-1',
    );
    await queue.update(
      action.copyWith(
        status: OfflineDeliveryActionStatus.failed,
        lastError: 'Backend unavailable',
      ),
    );
    final seller = controller.conversations.firstWhere(
      (item) => item.id == 'seller',
    );
    await controller.selectConversation(seller);
    expect(controller.messages.last.isFailed, isTrue);
    expect(await controller.retryFailedMessage(action.localId), isTrue);
    expect(queue.actions, isEmpty);
    expect(controller.messages.last.body, 'Retry this update');
  });
}

InMemoryRiderMessageRepository _repository(RiderConversationAccess access) =>
    InMemoryRiderMessageRepository(
      access: access,
      conversations: const [
        RiderConversation(
          id: 'seller',
          participantLabel: 'Farm',
          party: RiderConversationParty.seller,
          deliveryId: 'delivery-1',
          riderId: 'rider-1',
          unreadCount: 2,
        ),
        RiderConversation(
          id: 'buyer',
          participantLabel: 'Buyer',
          party: RiderConversationParty.buyer,
          deliveryId: 'delivery-2',
          riderId: 'rider-1',
        ),
        RiderConversation(
          id: 'support',
          participantLabel: 'Support',
          party: RiderConversationParty.support,
          riderId: 'rider-1',
          supportAuthorized: true,
        ),
        RiderConversation(
          id: 'other',
          participantLabel: 'Other',
          party: RiderConversationParty.buyer,
          deliveryId: 'delivery-9',
          riderId: 'rider-1',
        ),
      ],
      messages: [
        RiderChatMessage(
          id: 'message-read',
          conversationId: 'seller',
          sender: RiderMessageSender.rider,
          kind: RiderMessageKind.text,
          sentAt: DateTime(2026),
          body: 'Earlier update',
          status: RiderMessageDeliveryStatus.read,
        ),
      ],
    );

List<RiderNotification> _notifications() => [
  RiderNotification(
    id: 'n1',
    eventId: 'event-1',
    riderId: 'rider-1',
    type: RiderNotificationType.farmerMessage,
    title: 'Old',
    message: 'Old',
    createdAt: DateTime(2026),
    conversationId: 'seller',
  ),
  RiderNotification(
    id: 'n2',
    eventId: 'event-1',
    riderId: 'rider-1',
    type: RiderNotificationType.farmerMessage,
    title: 'Message',
    message: 'New',
    createdAt: DateTime(2026, 1, 2),
    conversationId: 'seller',
    canDelete: true,
  ),
  RiderNotification(
    id: 'n3',
    riderId: 'rider-1',
    type: RiderNotificationType.safetyUpdate,
    title: 'Safety',
    message: 'Reviewed',
    createdAt: DateTime(2026, 1, 3),
    deliveryId: 'delivery-1',
    reportId: 'report-1',
  ),
  RiderNotification(
    id: 'private',
    riderId: 'rider-2',
    type: RiderNotificationType.payment,
    title: 'Private',
    message: 'Hidden',
    createdAt: DateTime(2026),
  ),
];
