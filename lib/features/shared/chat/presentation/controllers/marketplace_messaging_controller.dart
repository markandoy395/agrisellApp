import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

part 'marketplace_messaging_controller_helpers.dart';

enum MarketplaceMessagingLoadState { initial, loading, ready, error }

class MarketplaceMessagingController extends ChangeNotifier {
  MarketplaceMessagingController({
    required this.repository,
    required this.actorRole,
  });

  final MarketplaceMessagingRepository repository;
  final MarketplaceActorRole actorRole;

  MarketplaceMessagingLoadState _state = MarketplaceMessagingLoadState.initial;
  List<MarketplaceConversation> _conversations = const [];
  final Map<String, List<MarketplaceMessage>> _messages = {};
  final Set<String> _loadingMessages = {};
  final Set<String> _sendingMessages = {};
  final Map<String, String> _messageErrors = {};
  String? _errorMessage;
  bool _isStarting = false;
  bool _isDisposed = false;

  MarketplaceMessagingLoadState get state => _state;
  List<MarketplaceConversation> get conversations => _conversations;
  String? get errorMessage => _errorMessage;
  bool get isStarting => _isStarting;

  List<MarketplaceMessage> messagesFor(String conversationId) =>
      List.unmodifiable(_messages[conversationId] ?? const []);
  bool isLoadingMessages(String id) => _loadingMessages.contains(id);
  bool isSending(String id) => _sendingMessages.contains(id);
  String? messageErrorFor(String id) => _messageErrors[id];

  Future<void> load({bool silent = false}) async {
    if (!silent || _conversations.isEmpty) {
      _state = MarketplaceMessagingLoadState.loading;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      _conversations = List.of(await repository.loadConversations());
      _state = MarketplaceMessagingLoadState.ready;
      _errorMessage = null;
    } on MarketplaceMessagingException catch (error) {
      _errorMessage = error.message;
      if (_conversations.isEmpty) _state = MarketplaceMessagingLoadState.error;
    } on Object {
      _errorMessage = 'Conversations could not be loaded. Please try again.';
      if (_conversations.isEmpty) _state = MarketplaceMessagingLoadState.error;
    }
    notifyListeners();
  }

  Future<MarketplaceConversation?> startConversation(
    MarketplaceConversationSeed seed,
  ) async {
    _isStarting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = await repository.startConversation(seed);
      await load(silent: true);
      return _conversations.where((item) => item.id == id).firstOrNull;
    } on MarketplaceMessagingException catch (error) {
      _errorMessage = error.message;
      return null;
    } on Object {
      _errorMessage = 'The conversation could not be opened.';
      return null;
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  Future<void> openConversation(String id, {bool refresh = false}) async {
    if (refresh && isSending(id)) return;
    if (_messages.containsKey(id) && !refresh) {
      await _markReadBestEffort(id);
      return;
    }
    final hasCachedMessages = _messages.containsKey(id);
    if (!hasCachedMessages) _loadingMessages.add(id);
    _messageErrors.remove(id);
    notifyListeners();
    try {
      final freshMessages = await repository.loadMessages(id);
      if (freshMessages.isNotEmpty || !hasCachedMessages) {
        _messages[id] = List.of(freshMessages);
      }
      await _markReadBestEffort(id);
    } on MarketplaceMessagingException catch (error) {
      _messageErrors[id] = error.message;
    } on Object {
      _messageErrors[id] = 'Messages could not be loaded. Please try again.';
    } finally {
      if (!hasCachedMessages) _loadingMessages.remove(id);
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String conversationId, String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || text.length > 1000 || isSending(conversationId)) {
      return false;
    }
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
      _replaceMessage(conversationId, local.id, saved);
      await _refreshAfterSend(conversationId);
      return true;
    } on MarketplaceMessagingException catch (error) {
      _replaceMessage(
        conversationId,
        local.id,
        local.copyWith(state: MarketplaceMessageState.failed),
      );
      _restoreSummary(previousConversation);
      _messageErrors[conversationId] = error.message;
      return false;
    } on Object {
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
    _messages[conversationId]?.removeWhere((item) => item.id == message.id);
    notifyListeners();
    return sendMessage(conversationId, message.text);
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
