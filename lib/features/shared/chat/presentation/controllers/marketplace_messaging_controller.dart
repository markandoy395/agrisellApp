import 'package:flutter/foundation.dart';
import 'package:agresell_app/core/utils/async_request_scope.dart';
import 'package:agresell_app/core/utils/async_operation_gate.dart';
import '../../domain/chat_limits.dart';

import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

part 'marketplace_messaging_controller_helpers.dart';
part 'marketplace_messaging_controller_sending.dart';

enum MarketplaceMessagingLoadState { initial, loading, ready, error }

class MarketplaceMessagingController extends ChangeNotifier {
  MarketplaceMessagingController({
    required this.repository,
    required this.actorRole,
  });

  final MarketplaceMessagingRepository repository;
  final MarketplaceActorRole actorRole;
  final _scope = AsyncRequestScope();
  final _requests = AsyncOperationGate();

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

  Future<void> load({bool silent = false}) => _requests.run(
    'conversations',
    () => _requests.serialize('inbox', () => _load(silent: silent)),
  );

  Future<void> _load({bool silent = false}) async {
    if (_isDisposed) return;
    final ticket = _scope.begin('conversations');
    if (!silent || _conversations.isEmpty) {
      _state = MarketplaceMessagingLoadState.loading;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final values = await repository.loadConversations();
      if (!ticket.isCurrent) return;
      _conversations = List.of(values);
      _state = MarketplaceMessagingLoadState.ready;
      _errorMessage = null;
    } on MarketplaceMessagingException catch (error) {
      if (!ticket.isCurrent) return;
      _errorMessage = error.message;
      if (_conversations.isEmpty) _state = MarketplaceMessagingLoadState.error;
    } on Object {
      if (!ticket.isCurrent) return;
      _errorMessage = 'Conversations could not be loaded. Please try again.';
      if (_conversations.isEmpty) _state = MarketplaceMessagingLoadState.error;
    }
    notifyListeners();
  }

  Future<MarketplaceConversation?> startConversation(
    MarketplaceConversationSeed seed,
  ) async {
    if (_isStarting || _isDisposed) return null;
    final ticket = _scope.begin('start');
    _isStarting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final id = await repository.startConversation(seed);
      if (!ticket.isCurrent) return null;
      await load(silent: true);
      return _conversations.where((item) => item.id == id).firstOrNull;
    } on MarketplaceMessagingException catch (error) {
      if (!ticket.isCurrent) return null;
      _errorMessage = error.message;
      return null;
    } on Object {
      if (!ticket.isCurrent) return null;
      _errorMessage = 'The conversation could not be opened.';
      return null;
    } finally {
      _isStarting = false;
      notifyListeners();
    }
  }

  Future<void> openConversation(String id, {bool refresh = false}) => _requests
      .run(('messages', id), () => _openConversation(id, refresh: refresh));

  Future<void> _openConversation(String id, {bool refresh = false}) async {
    if (_isDisposed) return;
    final ticket = _scope.begin(('messages', id));
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
      if (!ticket.isCurrent || isSending(id)) return;
      if (freshMessages.isNotEmpty || !hasCachedMessages) {
        _messages[id] = List.of(freshMessages);
      }
      await _markReadBestEffort(id);
    } on MarketplaceMessagingException catch (error) {
      if (!ticket.isCurrent) return;
      _messageErrors[id] = error.message;
    } on Object {
      if (!ticket.isCurrent) return;
      _messageErrors[id] = 'Messages could not be loaded. Please try again.';
    } finally {
      if (!hasCachedMessages) _loadingMessages.remove(id);
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _scope.dispose();
    _isDisposed = true;
    super.dispose();
  }
}
