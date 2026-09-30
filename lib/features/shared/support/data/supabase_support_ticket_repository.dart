import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

class SupabaseSupportTicketRepository implements SupportTicketRepository {
  SupabaseSupportTicketRepository({SupabaseClient? client})
    : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  @override
  Future<List<SupportTicket>> getMyTickets() async {
    try {
      final res = await _client.rpc('current_user_support_tickets');
      if (res is List) {
        return res
            .map(
              (item) => SupportTicket.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      }
    } on PostgrestException catch (_) {
      // Fallback: direct query to support_tickets table if RPC is restricted or unmigrated
      final rows = await _client
          .from('support_tickets')
          .select()
          .order('updated_at', ascending: false);

      return (rows as List)
          .map(
            (item) =>
                SupportTicket.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    }
    return const [];
  }

  @override
  Future<SupportTicket> createTicket({
    required String subject,
    required SupportTicketCategory category,
    required String message,
    SupportTicketPriority priority = SupportTicketPriority.medium,
    int? orderId,
    int? deliveryId,
  }) async {
    try {
      final res = await _client.rpc(
        'submit_customer_support_ticket',
        params: {
          'p_subject': subject.trim(),
          'p_category': category.dbValue,
          'p_message': message.trim(),
          'p_priority': priority.dbValue,
        },
      );

      final map = res is Map ? Map<String, dynamic>.from(res) : null;
      final ticketId = (map?['ticket_id'] as num?)?.toInt() ?? 0;
      final ticketNumber = map?['ticket_number']?.toString() ?? '';

      return SupportTicket(
        ticketId: ticketId,
        ticketNumber: ticketNumber,
        subject: subject.trim(),
        category: category,
        status: SupportTicketStatus.open,
        priority: priority,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastMessage: message.trim(),
        orderId: orderId,
        deliveryId: deliveryId,
      );
    } on PostgrestException catch (_) {
      // Fallback: direct insert into support_tickets table
      final user = _client.auth.currentUser;
      if (user == null) {
        throw StateError('You must be signed in to submit a support ticket.');
      }

      final ticketRow = await _client
          .from('support_tickets')
          .insert({
            'ticket_number': 'TCK-${DateTime.now().millisecondsSinceEpoch}',
            'subject': subject.trim(),
            'category': category.dbValue,
            'priority': priority.dbValue,
            'status': 'open',
            if (orderId != null) 'order_id': orderId,
            if (deliveryId != null) 'delivery_id': deliveryId,
          })
          .select()
          .single();

      final createdTicket = SupportTicket.fromJson(
        Map<String, dynamic>.from(ticketRow),
      );

      // Insert initial message
      await _client.from('support_messages').insert({
        'ticket_id': createdTicket.ticketId,
        'sender_role': 'user',
        'sender_name': user.email ?? 'Customer',
        'body': message.trim(),
      });

      return createdTicket.copyWith(lastMessage: message.trim());
    }
  }

  @override
  Future<List<SupportMessage>> getTicketMessages(int ticketId) async {
    try {
      final rows = await _client
          .from('support_messages')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      return (rows as List)
          .map(
            (item) =>
                SupportMessage.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  }) async {
    try {
      final res = await _client.rpc(
        'send_customer_support_message',
        params: {'p_ticket_id': ticketId, 'p_body': body.trim()},
      );

      if (res is Map) {
        return SupportMessage.fromJson(Map<String, dynamic>.from(res));
      }
    } on PostgrestException catch (_) {
      // Fallback: direct insert to support_messages and update support_tickets
      final user = _client.auth.currentUser;
      final msgRow = await _client
          .from('support_messages')
          .insert({
            'ticket_id': ticketId,
            'sender_role': 'user',
            'sender_name': user?.email ?? 'Customer',
            'body': body.trim(),
          })
          .select()
          .single();

      // Re-open ticket if closed/resolved
      await _client
          .from('support_tickets')
          .update({'status': 'open', 'updated_at': DateTime.now().toIso8601String()})
          .eq('ticket_id', ticketId);

      return SupportMessage.fromJson(Map<String, dynamic>.from(msgRow));
    }

    throw StateError('Failed to send support message.');
  }
}
