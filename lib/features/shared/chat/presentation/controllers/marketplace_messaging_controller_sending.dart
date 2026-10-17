part of 'marketplace_messaging_controller.dart';

extension MarketplaceMessagingSending on MarketplaceMessagingController {
  Future<bool> sendMessage(String conversationId, String rawText) async {
    if (_isDisposed) return false;
    final text = rawText.trim();
    if (!ChatLimits.valid(rawText)) {
      _messageErrors[conversationId] = ChatLimits.lengthError;
      notifyListeners();
      return false;
    }
    if (isSending(conversationId)) {
      return false;
    }
    final ticket = _scope.begin(('send', conversationId));
    _scope.invalidate(('messages', conversationId));
    _scope.invalidate('conversations');
    final previousConversation = _conversation(conversationId);
    final local = MarketplaceMessage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}',
      senderRole: actorRole,
      text: text,
      sentAt: DateTime.now(),
      state: MarketplaceMessageState.sending,
    );
    _messages.putIfAbsent(conversationId, () => []).add(local);
    _sendingMessages.add(conversationId);
    _messageErrors.remove(conversationId);
    _updateSummary(conversationId, text, local.sentAt);
    notifyListeners();

    try {
      final saved = await repository.sendMessage(
        conversationId: conversationId,
        text: text,
      );
      if (!ticket.isCurrent) return false;
      _replaceMessage(conversationId, local.id, saved);
      await _refreshAfterSend(conversationId);
      return true;
    } on MarketplaceMessagingException catch (error) {
      if (!ticket.isCurrent) return false;
      _replaceMessage(
        conversationId,
        local.id,
        local.copyWith(state: MarketplaceMessageState.failed),
      );
      _restoreSummary(previousConversation);
      _messageErrors[conversationId] = error.message;
      return false;
    } on Object {
      if (!ticket.isCurrent) return false;
      _replaceMessage(
        conversationId,
        local.id,
        local.copyWith(state: MarketplaceMessageState.failed),
      );
      _restoreSummary(previousConversation);
      _messageErrors[conversationId] =
          'Your message was not sent. Tap it to retry.';
      return false;
    } finally {
      _sendingMessages.remove(conversationId);
      notifyListeners();
    }
  }

  Future<bool> retryMessage(String conversationId, MarketplaceMessage message) {
    if (isSending(conversationId)) return Future.value(false);
    _messages[conversationId]?.removeWhere((item) => item.id == message.id);
    notifyListeners();
    return sendMessage(conversationId, message.text);
  }
}
