part of 'rider_messages_controller.dart';

extension RiderMessagesControllerOffline on RiderMessagesController {
  List<RiderChatMessage> get pendingTextMessages => [
    for (final conversation in conversations)
      ..._pendingMessages(
        conversation.id,
      ).where((message) => message.kind == RiderMessageKind.text),
  ];

  Future<bool> requestAction(RiderCommunicationActionType type) async {
    final riderId = _riderId;
    final conversation = _selectedConversation;
    if (riderId == null || conversation == null) return false;
    try {
      await _repository.requestAction(
        riderId: riderId,
        action: RiderCommunicationAction(
          type: type,
          conversationId: conversation.id,
          deliveryId: conversation.deliveryId,
        ),
      );
      return true;
    } on RiderMessageRepositoryException catch (error) {
      _messageError = error.message;
    } catch (_) {
      _messageError = 'This action is unavailable right now.';
    }
    _notify();
    return false;
  }

  void setBackendReachable(bool reachable) {
    _backendReachable = reachable;
    if (reachable) unawaited(synchronizePendingMessages());
  }

  Future<void> synchronizePendingMessages() async {
    final riderId = _riderId;
    if (!_backendReachable || riderId == null) return;
    final pending = _offlineQueue.actions.where(
      (action) =>
          action.type == OfflineDeliveryActionType.message &&
          action.status == OfflineDeliveryActionStatus.pending,
    );
    for (final action in pending.toList()) {
      try {
        await _repository.sendMessage(
          riderId: riderId,
          draft: RiderMessageDraft(
            conversationId: action.payload['conversationId'] as String,
            body: action.payload['body'] as String? ?? '',
            kind: RiderMessageKind.values.byName(
              action.payload['kind'] as String? ?? RiderMessageKind.text.name,
            ),
            attachmentReference:
                action.payload['attachmentReference'] as String?,
            idempotencyKey: action.idempotencyKey,
          ),
        );
        await _offlineQueue.acknowledge(action.localId);
      } on RiderMessageRepositoryException catch (error) {
        if (error.isOffline) _backendReachable = false;
        final retries = action.retryCount + 1;
        await _offlineQueue.update(
          action.copyWith(
            status: retries >= action.maxRetries
                ? OfflineDeliveryActionStatus.failed
                : OfflineDeliveryActionStatus.pending,
            lastError: error.message,
            retryCount: retries,
          ),
        );
        break;
      }
    }
    final selected = _selectedConversation;
    if (selected != null) await selectConversation(selected);
  }

  Future<bool> retryFailedMessage(String localId) async {
    final action = _offlineQueue.actions.where(
      (item) =>
          item.localId == localId &&
          item.type == OfflineDeliveryActionType.message,
    );
    if (action.isEmpty || !await _offlineQueue.retry(localId)) return false;
    await synchronizePendingMessages();
    return true;
  }

  Future<void> _queueMessage(
    String riderId,
    RiderConversation conversation,
    RiderMessageDraft draft,
  ) async {
    final now = DateTime.now();
    final action = await _offlineQueue.add(
      riderId: riderId,
      deliveryId: conversation.deliveryId ?? 'conversation:${conversation.id}',
      type: OfflineDeliveryActionType.message,
      payload: {
        'conversationId': conversation.id,
        'body': draft.body,
        'kind': draft.kind.name,
        'attachmentReference': draft.attachmentReference,
      },
      originalTimestamp: now,
      idempotencyKey: draft.idempotencyKey,
    );
    if (_selectedConversation?.id == conversation.id) {
      _messages = [
        ..._messages,
        RiderChatMessage(
          id: action.localId,
          conversationId: conversation.id,
          sender: RiderMessageSender.rider,
          kind: draft.kind,
          body: draft.body,
          attachmentReference: draft.attachmentReference,
          sentAt: now,
          status: RiderMessageDeliveryStatus.pending,
        ),
      ];
    }
    _isSending = false;
    _messageError = 'Message saved. Waiting to synchronize.';
    _notify();
  }

  List<RiderChatMessage> _pendingMessages(String conversationId) =>
      _offlineQueue.actions
          .where(
            (action) =>
                action.type == OfflineDeliveryActionType.message &&
                action.payload['conversationId'] == conversationId,
          )
          .map(
            (action) => RiderChatMessage(
              id: action.localId,
              conversationId: conversationId,
              sender: RiderMessageSender.rider,
              kind: RiderMessageKind.values.byName(
                action.payload['kind'] as String? ?? RiderMessageKind.text.name,
              ),
              body: action.payload['body'] as String? ?? '',
              attachmentReference:
                  action.payload['attachmentReference'] as String?,
              sentAt: action.originalTimestamp,
              status: action.status == OfflineDeliveryActionStatus.failed
                  ? RiderMessageDeliveryStatus.failed
                  : RiderMessageDeliveryStatus.pending,
              failureReason: action.lastError,
            ),
          )
          .toList();
}
