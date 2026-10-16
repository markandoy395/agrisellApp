import 'dart:async';
import 'package:agresell_app/features/shared/chat/data/chat_rpc.dart';
import 'package:agresell_app/features/shared/chat/domain/chat_limits.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';

class SupabaseRiderMessageRepository implements RiderMessageRepository {
  SupabaseRiderMessageRepository({SupabaseClient? client})
    : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  @override
  Stream<List<RiderConversation>> watchConversations({
    required String riderId,
  }) {
    late final StreamController<List<RiderConversation>> controller;
    RealtimeChannel? channel;
    var refreshing = false;
    var refreshAgain = false;

    Future<void> refresh() async {
      if (refreshing) {
        refreshAgain = true;
        return;
      }
      refreshing = true;
      do {
        refreshAgain = false;
        try {
          final conversations = await _fetchConversations(riderId);
          if (!controller.isClosed) controller.add(conversations);
        } catch (error, stackTrace) {
          if (!controller.isClosed) controller.addError(error, stackTrace);
        }
      } while (refreshAgain && !controller.isClosed);
      refreshing = false;
    }

    controller = StreamController<List<RiderConversation>>(
      onListen: () {
        channel = _client
            .channel(
              'rider-conversations:$riderId:'
              '${DateTime.now().microsecondsSinceEpoch}',
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.all,
              schema: 'public',
              table: 'rider_delivery_messages',
              callback: (_) => unawaited(refresh()),
            )
            .subscribe();
        unawaited(refresh());
      },
      onCancel: () async {
        final active = channel;
        if (active != null) await _client.removeChannel(active);
      },
    );
    return controller.stream;
  }

  Future<List<RiderConversation>> _fetchConversations(String riderId) async {
    final value = await _client.rpc<Object?>('current_rider_conversations');
    return _rows(
      value,
    ).map((row) => _conversation(row, riderId)).toList(growable: false);
  }

  @override
  Future<List<RiderChatMessage>> fetchMessages({
    required String riderId,
    required String conversationId,
  }) async {
    final value = await _client.rpc<Object?>(
      'current_rider_conversation_messages',
      params: {'p_conversation_id': conversationId},
    );
    return _rows(value).map(_message).toList(growable: false);
  }

  @override
  Future<RiderChatMessage> sendMessage({
    required String riderId,
    required RiderMessageDraft draft,
  }) async {
    try {
      if (ChatLimits.length(draft.body) > ChatLimits.messageCharacters) {
        throw const RiderMessageRepositoryException(ChatLimits.lengthError);
      }
      final value = await ChatRpc.call(_client, 'send_rider_delivery_message', {
        'p_conversation_id': draft.conversationId,
        'p_body': draft.body.trim(),
        'p_kind': draft.kind.name,
        'p_attachment_reference': draft.attachmentReference,
        'p_idempotency_key': draft.idempotencyKey,
      });
      return _message(_map(value));
    } on PostgrestException catch (error) {
      throw RiderMessageRepositoryException(
        ChatLimits.serverError(error.code) ?? error.message,
        isOffline: _offlineCode(error.code),
      );
    }
  }

  @override
  Future<void> markConversationRead({
    required String riderId,
    required String conversationId,
  }) => _client.rpc<void>(
    'mark_current_rider_conversation_read',
    params: {'p_conversation_id': conversationId},
  );

  @override
  Future<void> requestAction({
    required String riderId,
    required RiderCommunicationAction action,
  }) async {
    final conversations = await _fetchConversations(riderId);
    if (!conversations.any((item) => item.id == action.conversationId)) {
      throw const RiderMessageRepositoryException(
        'Conversation access is not authorized.',
      );
    }
  }

  RiderConversation _conversation(Map<String, Object?> row, String riderId) =>
      RiderConversation(
        id: '${row['conversation_id']}',
        participantLabel: '${row['participant_label']}',
        party: switch ('${row['party']}') {
          'buyer' => RiderConversationParty.buyer,
          'support' => RiderConversationParty.support,
          _ => RiderConversationParty.seller,
        },
        deliveryId: row['delivery_id']?.toString(),
        riderId: row['rider_id']?.toString() ?? riderId,
        supportAuthorized: row['support_authorized'] == true,
        lastMessagePreview: _optionalText(row['last_message_preview']),
        lastActivity: _date(row['last_activity']),
        unreadCount: (row['unread_count'] as num?)?.toInt() ?? 0,
      );

  RiderChatMessage _message(Map<String, Object?> row) => RiderChatMessage(
    id: '${row['message_id']}',
    conversationId: 'delivery:${row['delivery_id']}:${row['party']}',
    sender: switch ('${row['sender_role']}') {
      'rider' => RiderMessageSender.rider,
      'system' => RiderMessageSender.system,
      _ => RiderMessageSender.participant,
    },
    kind: RiderMessageKind.values.firstWhere(
      (item) => item.name == row['message_kind'],
      orElse: () => RiderMessageKind.text,
    ),
    body: '${row['body'] ?? ''}',
    attachmentReference: _optionalText(row['attachment_reference']),
    sentAt: _date(row['sent_at']) ?? DateTime.now(),
    status: RiderMessageDeliveryStatus.delivered,
  );
}

List<Map<String, Object?>> _rows(Object? value) =>
    value is List ? value.map(_map).toList(growable: false) : const [];

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};

String? _optionalText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _date(Object? value) => DateTime.tryParse(value?.toString() ?? '');

bool _offlineCode(String? code) =>
    code == null || code == 'PGRST000' || code == '08006';
