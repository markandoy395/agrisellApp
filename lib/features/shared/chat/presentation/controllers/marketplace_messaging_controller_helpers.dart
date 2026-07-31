part of 'marketplace_messaging_controller.dart';

extension _MarketplaceMessagingControllerHelpers
    on MarketplaceMessagingController {
  Future<void> _markReadBestEffort(String id) async {
    try {
      await repository.markRead(id);
      final index = _conversations.indexWhere((item) => item.id == id);
      if (index >= 0) {
        _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      }
    } on Object {
      // Reading remains available when the acknowledgement cannot be saved.
    }
  }

  Future<void> _refreshAfterSend(String id) async {
    try {
      final freshMessages = await repository.loadMessages(id);
      if (freshMessages.isNotEmpty || (_messages[id]?.isEmpty ?? true)) {
        _messages[id] = List.of(freshMessages);
      }
      _conversations = List.of(await repository.loadConversations());
    } on Object {
      // The confirmed message remains visible when a follow-up refresh fails.
    }
  }

  MarketplaceConversation? _conversation(String id) =>
      _conversations.where((item) => item.id == id).firstOrNull;

  void _restoreSummary(MarketplaceConversation? previous) {
    if (previous == null) return;
    final index = _conversations.indexWhere((item) => item.id == previous.id);
    if (index >= 0) _conversations[index] = previous;
  }

  void _updateSummary(String id, String text, DateTime sentAt) {
    final index = _conversations.indexWhere((item) => item.id == id);
    if (index < 0) return;
    _conversations[index] = _conversations[index].copyWith(
      lastMessage: text,
      updatedAt: sentAt,
    );
  }

  void _replaceMessage(
    String id,
    String oldId,
    MarketplaceMessage replacement,
  ) {
    final list = _messages[id];
    final index = list?.indexWhere((item) => item.id == oldId) ?? -1;
    if (index >= 0) {
      list![index] = replacement;
    } else {
      _messages.putIfAbsent(id, () => []).add(replacement);
    }
  }
}
