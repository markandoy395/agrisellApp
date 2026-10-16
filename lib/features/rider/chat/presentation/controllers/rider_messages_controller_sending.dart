part of 'rider_messages_controller.dart';

extension RiderMessagesControllerSending on RiderMessagesController {
  Future<bool> send(String body) =>
      _sendForSelection(body: body, kind: RiderMessageKind.text);

  Future<bool> sendPhoto(String protectedReference) => _sendForSelection(
    kind: RiderMessageKind.photo,
    attachmentReference: protectedReference,
  );

  Future<bool> sendLocation(String protectedReference) => _sendForSelection(
    kind: RiderMessageKind.location,
    attachmentReference: protectedReference,
  );

  Future<bool> sendDeliveryUpdate(String message) =>
      _sendForSelection(body: message, kind: RiderMessageKind.deliveryUpdate);

  Future<bool> _sendForSelection({
    String body = '',
    RiderMessageKind kind = RiderMessageKind.text,
    String? attachmentReference,
  }) {
    final conversation = _selectedConversation;
    if (conversation == null) return Future.value(false);
    return sendDraft(
      RiderMessageDraft(
        conversationId: conversation.id,
        body: body,
        kind: kind,
        attachmentReference: attachmentReference,
      ),
    );
  }

  Future<bool> sendDraft(RiderMessageDraft draft) async {
    if (_isSending) return false;
    final queued = _offlineQueue.actions
        .where(
          (action) =>
              action.riderId == _riderId &&
              action.type == OfflineDeliveryActionType.message &&
              action.status != OfflineDeliveryActionStatus.synchronized &&
              action.status != OfflineDeliveryActionStatus.cancelled,
        )
        .length;
    if (queued >= ChatLimits.messagesPerAccountDay) {
      _setSendError(
        'Your offline message queue is full. Reconnect before sending more.',
      );
      return false;
    }
    if (ChatLimits.length(draft.body) > ChatLimits.messageCharacters) {
      _setSendError(ChatLimits.lengthError);
      return false;
    }
    final riderId = _riderId;
    final conversation = _selectedConversation;
    if (riderId == null ||
        conversation == null ||
        draft.conversationId != conversation.id ||
        (draft.kind == RiderMessageKind.text && draft.body.trim().isEmpty) ||
        (draft.kind != RiderMessageKind.text &&
            draft.body.trim().isEmpty &&
            draft.attachmentReference == null)) {
      return false;
    }
    _isSending = true;
    _messageError = null;
    _notify();
    if (!_backendReachable) {
      await _queueMessage(riderId, conversation, draft);
      return true;
    }
    try {
      final message = await _repository.sendMessage(
        riderId: riderId,
        draft: draft,
      );
      if (_selectedConversation?.id == conversation.id) {
        _messages = [..._messages, message];
      }
      _isSending = false;
      _notify();
      return true;
    } on RiderMessageRepositoryException catch (error) {
      if (error.isOffline) {
        _backendReachable = false;
        await _queueMessage(riderId, conversation, draft);
        return true;
      }
      _setSendError(error.message);
    } catch (_) {
      _setSendError('Message could not be sent.');
    }
    return false;
  }
}
