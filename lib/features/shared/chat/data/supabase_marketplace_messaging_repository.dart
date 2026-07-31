import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_remote.dart';
import 'package:agresell_app/features/shared/chat/data/marketplace_messaging_repository.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';

class SupabaseMarketplaceMessagingRepository
    implements MarketplaceMessagingRepository {
  SupabaseMarketplaceMessagingRepository(SupabaseClient client)
    : this.withRemote(SupabaseMarketplaceMessagingRemote(client));

  const SupabaseMarketplaceMessagingRepository.withRemote(this.remote);

  final MarketplaceMessagingRemote remote;

  @override
  Future<List<MarketplaceConversation>> loadConversations() async {
    try {
      final response = await remote.call('current_marketplace_conversations');
      return _rows(
        response,
      ).map(MarketplaceConversation.fromJson).toList(growable: false);
    } on Object catch (error) {
      throw MarketplaceMessagingException(
        'We could not load your conversations. Please try again.',
        error,
      );
    }
  }

  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) async {
    try {
      final response = await remote.call(
        'marketplace_conversation_messages',
        parameters: {'conversation_id': _id(conversationId)},
      );
      return _rows(
        response,
      ).map(MarketplaceMessage.fromJson).toList(growable: false);
    } on Object catch (error) {
      throw MarketplaceMessagingException(
        'Messages could not be loaded. Please try again.',
        error,
      );
    }
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await remote.call(
        'mark_marketplace_conversation_read',
        parameters: {'conversation_id': _id(conversationId)},
      );
    } on Object catch (error) {
      throw MarketplaceMessagingException(
        'The conversation could not be marked as read.',
        error,
      );
    }
  }

  @override
  Future<MarketplaceMessage> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      final response = await remote.call(
        'send_marketplace_message',
        parameters: {'conversation_id': _id(conversationId), 'body': text},
      );
      final row = _map(response);
      if (row == null) throw const FormatException('Missing message response');
      return MarketplaceMessage.fromJson(row);
    } on Object catch (error) {
      throw MarketplaceMessagingException(
        'Your message was not sent. Tap it to retry.',
        error,
      );
    }
  }

  @override
  Future<String> startConversation(MarketplaceConversationSeed seed) async {
    try {
      final commodityId = seed.commodityId == null
          ? null
          : _id(seed.commodityId!);
      final response = await remote.call(
        'start_marketplace_conversation',
        parameters: {
          'commodity_id': commodityId,
          'farm_id': seed.farmId,
          'client_order_id': seed.clientOrderId,
        },
      );
      final id = response?.toString() ?? '';
      if (id.isEmpty) throw const FormatException('Missing conversation id');
      return id;
    } on Object catch (error) {
      throw MarketplaceMessagingException(
        'We could not open a conversation with this farmer.',
        error,
      );
    }
  }

  int _id(String value) {
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      throw const FormatException('Invalid marketplace identifier');
    }
    return parsed;
  }

  List<Map<String, Object?>> _rows(Object? value) {
    final decoded = value is String ? jsonDecode(value) : value;
    if (decoded is! List) return const [];
    return decoded.map(_map).whereType<Map<String, Object?>>().toList();
  }

  Map<String, Object?>? _map(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }
}
