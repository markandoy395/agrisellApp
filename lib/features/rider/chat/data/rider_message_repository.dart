import 'dart:async';

import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';

/// Contract for delivery-scoped chat. A remote implementation must authorize
/// the rider before returning conversations or accepting a message.
abstract interface class RiderMessageRepository {
  Stream<List<RiderConversation>> watchConversations({required String riderId});

  Future<List<RiderChatMessage>> fetchMessages({
    required String riderId,
    required String conversationId,
  });

  Future<RiderChatMessage> sendMessage({
    required String riderId,
    required RiderMessageDraft draft,
  });

  Future<void> markConversationRead({
    required String riderId,
    required String conversationId,
  });

  Future<void> requestAction({
    required String riderId,
    required RiderCommunicationAction action,
  });
}

/// Empty, in-memory adapter for local development and widget tests.
///
/// It has no seeded conversations and should be replaced by a secure chat API.
class InMemoryRiderMessageRepository implements RiderMessageRepository {
  InMemoryRiderMessageRepository({
    Iterable<RiderConversation> conversations = const [],
    Iterable<RiderChatMessage> messages = const [],
    this.access = const RiderConversationAccess(),
  }) : _conversations = {
         for (final conversation in conversations)
           conversation.id: conversation,
       },
       _messages = _groupMessages(messages);

  final Map<String, RiderConversation> _conversations;
  final Map<String, List<RiderChatMessage>> _messages;
  final RiderConversationAccess access;
  final Map<String, RiderChatMessage> _sentByIdempotencyKey = {};
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<RiderConversation>> watchConversations({
    required String riderId,
  }) {
    return Stream.multi((controller) {
      void emit() => controller.add(_currentConversations(riderId));
      emit();
      final subscription = _changes.stream.listen((_) => emit());
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<List<RiderChatMessage>> fetchMessages({
    required String riderId,
    required String conversationId,
  }) async => List<RiderChatMessage>.unmodifiable(
    _messages[_conversationFor(riderId, conversationId).id] ?? [],
  );

  @override
  Future<RiderChatMessage> sendMessage({
    required String riderId,
    required RiderMessageDraft draft,
  }) async {
    final conversation = _conversationFor(riderId, draft.conversationId);
    final key = draft.idempotencyKey;
    if (key != null) {
      final replay = _sentByIdempotencyKey[key];
      if (replay != null) return replay;
    }
    if (!_isProtectedDraft(draft)) {
      throw const RiderMessageRepositoryException(
        'Photos and locations require a protected reference.',
      );
    }
    final sentAt = DateTime.now();
    final message = RiderChatMessage(
      id: 'local-${sentAt.microsecondsSinceEpoch}',
      conversationId: draft.conversationId,
      sender: RiderMessageSender.rider,
      kind: draft.kind,
      body: draft.body,
      sentAt: sentAt,
      attachmentReference: draft.attachmentReference,
      status: RiderMessageDeliveryStatus.sent,
    );
    _messages.putIfAbsent(draft.conversationId, () => []).add(message);
    _conversations[draft.conversationId] = conversation.copyWith(
      lastMessagePreview: _preview(message),
      lastActivity: sentAt,
      unreadCount: 0,
    );
    _changes.add(null);
    if (key != null) _sentByIdempotencyKey[key] = message;
    return message;
  }

  @override
  Future<void> markConversationRead({
    required String riderId,
    required String conversationId,
  }) async {
    final conversation = _conversations[conversationId];
    _conversationFor(riderId, conversationId);
    if (conversation == null || conversation.unreadCount == 0) return;
    _conversations[conversationId] = conversation.copyWith(unreadCount: 0);
    _changes.add(null);
  }

  @override
  Future<void> requestAction({
    required String riderId,
    required RiderCommunicationAction action,
  }) async {
    _conversationFor(riderId, action.conversationId);
  }

  RiderConversation _conversationFor(String riderId, String conversationId) {
    final conversation = _conversations[conversationId];
    if (conversation == null || !access.allows(conversation, riderId)) {
      throw const RiderMessageRepositoryException(
        'Conversation access is not authorized.',
      );
    }
    return conversation;
  }

  String _preview(RiderChatMessage message) {
    if (message.body.isNotEmpty) return message.body;
    return switch (message.kind) {
      RiderMessageKind.photo => 'Shared a protected photo',
      RiderMessageKind.location => 'Shared delivery location',
      RiderMessageKind.deliveryUpdate ||
      RiderMessageKind.system => 'Sent a delivery update',
      RiderMessageKind.text => '',
    };
  }

  List<RiderConversation> _currentConversations(String riderId) {
    final conversations = _conversations.values
        .where((conversation) => access.allows(conversation, riderId))
        .toList();
    conversations.sort((a, b) {
      final aTime = a.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.lastActivity ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return List<RiderConversation>.unmodifiable(conversations);
  }

  bool _isProtectedDraft(RiderMessageDraft draft) {
    if (draft.kind != RiderMessageKind.photo &&
        draft.kind != RiderMessageKind.location) {
      return true;
    }
    final reference = draft.attachmentReference?.trim() ?? '';
    return reference.startsWith('protected://') ||
        reference.startsWith('local-secure://');
  }

  static Map<String, List<RiderChatMessage>> _groupMessages(
    Iterable<RiderChatMessage> messages,
  ) {
    final grouped = <String, List<RiderChatMessage>>{};
    for (final message in messages) {
      grouped.putIfAbsent(message.conversationId, () => []).add(message);
    }
    return grouped;
  }
}

class RiderMessageRepositoryException implements Exception {
  const RiderMessageRepositoryException(this.message, {this.isOffline = false});

  final String message;
  final bool isOffline;

  @override
  String toString() => message;
}
