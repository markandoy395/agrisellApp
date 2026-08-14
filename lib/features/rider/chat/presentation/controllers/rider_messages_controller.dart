import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/data/supabase_rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_state.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

part 'rider_messages_controller_offline.dart';
part 'rider_messages_controller_sending.dart';

class RiderMessagesController extends ChangeNotifier {
  RiderMessagesController({
    RiderMessageRepository? repository,
    RiderOfflineActionQueue? offlineQueue,
  }) : _repository = repository ?? _defaultMessageRepository(),
       _offlineQueue = offlineQueue ?? RiderOfflineActionQueue(),
       _ownsQueue = offlineQueue == null;

  final RiderMessageRepository _repository;
  final RiderOfflineActionQueue _offlineQueue;
  final bool _ownsQueue;
  RiderCommunicationLoadState _state = RiderCommunicationLoadState.ready;
  StreamSubscription<List<RiderConversation>>? _subscription;
  List<RiderConversation> _conversations = const [];
  List<RiderChatMessage> _messages = const [];
  RiderConversation? _selectedConversation;
  String? _riderId;
  String? _errorMessage;
  String? _messageError;
  var _isLoadingMessages = false;
  var _isSending = false;
  var _backendReachable = true;
  var _isDisposed = false;
  RiderConversationAccess? _access;

  RiderCommunicationLoadState get state => _state;
  List<RiderConversation> get conversations =>
      List.unmodifiable(_conversations);
  List<RiderChatMessage> get messages => List.unmodifiable(_messages);
  RiderConversation? get selectedConversation => _selectedConversation;
  String? get errorMessage => _errorMessage;
  String? get messageError => _messageError;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  bool get canCompose => _riderId != null && _selectedConversation != null;

  Future<void> load({
    required String riderId,
    RiderConversationAccess access = const RiderConversationAccess(),
  }) async {
    await _subscription?.cancel();
    if (_isDisposed) return;
    _riderId = riderId;
    _access = access;
    _state = RiderCommunicationLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    await _offlineQueue.initialize(riderId);
    if (_isDisposed) return;
    _subscription = _repository
        .watchConversations(riderId: riderId)
        .listen(_onConversations, onError: _onConversationError);
  }

  Future<void> selectConversation(RiderConversation conversation) async {
    final riderId = _riderId;
    if (riderId == null) return;
    if (!(_access?.allows(conversation, riderId) ?? false)) {
      _messageError = 'Conversation access is not authorized.';
      notifyListeners();
      return;
    }
    _selectedConversation = conversation;
    _isLoadingMessages = true;
    _messageError = null;
    notifyListeners();
    try {
      final messages = await _repository.fetchMessages(
        riderId: riderId,
        conversationId: conversation.id,
      );
      if (_selectedConversation?.id == conversation.id) {
        _messages = [...messages, ..._pendingMessages(conversation.id)];
        _isLoadingMessages = false;
        notifyListeners();
      }
      unawaited(
        _repository.markConversationRead(
          riderId: riderId,
          conversationId: conversation.id,
        ),
      );
    } on RiderMessageRepositoryException catch (error) {
      _setMessageError(conversation.id, error.message);
    } catch (_) {
      _setMessageError(conversation.id, 'Messages could not be loaded.');
    }
  }

  void closeConversation() {
    _selectedConversation = null;
    _messages = const [];
    _messageError = null;
    notifyListeners();
  }

  void _onConversations(List<RiderConversation> conversations) {
    final riderId = _riderId;
    _conversations = List.unmodifiable([
      for (final conversation in conversations)
        if (riderId != null &&
            (_access?.allows(conversation, riderId) ?? false))
          conversation,
    ]);
    _state = RiderCommunicationLoadState.ready;
    _errorMessage = null;
    final selectedId = _selectedConversation?.id;
    if (selectedId != null) {
      _selectedConversation = _conversations
          .where((item) => item.id == selectedId)
          .firstOrNull;
    }
    notifyListeners();
  }

  void _onConversationError(Object error, StackTrace stackTrace) {
    _state = error is RiderMessageRepositoryException && error.isOffline
        ? RiderCommunicationLoadState.offline
        : RiderCommunicationLoadState.error;
    _errorMessage = error is RiderMessageRepositoryException
        ? error.message
        : 'Conversations could not be loaded.';
    notifyListeners();
  }

  void _setMessageError(String conversationId, String message) {
    if (_selectedConversation?.id != conversationId) return;
    _isLoadingMessages = false;
    _messageError = message;
    notifyListeners();
  }

  void _setSendError(String message) {
    _isSending = false;
    _messageError = message;
    notifyListeners();
  }

  void _notify() => notifyListeners();

  @override
  void notifyListeners() {
    if (!_isDisposed) super.notifyListeners();
  }

  @override
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _subscription?.cancel();
    if (_ownsQueue) _offlineQueue.dispose();
    super.dispose();
  }
}

RiderMessageRepository _defaultMessageRepository() {
  if (AgrisellSupabase.isInitialized &&
      AgrisellSupabase.client.auth.currentUser != null) {
    return SupabaseRiderMessageRepository();
  }
  return InMemoryRiderMessageRepository();
}
