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
    final res = await _client.rpc('current_user_support_tickets');
    if (res is List) {
      return res
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
  }

  @override
  Future<List<SupportMessage>> getTicketMessages(int ticketId) async {
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
  }

  @override
  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  }) async {
    final res = await _client.rpc(
      'send_customer_support_message',
      params: {'p_ticket_id': ticketId, 'p_body': body.trim()},
    );

    if (res is Map) {
      return SupportMessage.fromJson(Map<String, dynamic>.from(res));
    }

    throw StateError('Failed to send support message.');
  }
}
