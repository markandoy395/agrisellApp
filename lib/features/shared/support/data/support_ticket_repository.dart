import 'dart:math';

import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';

abstract interface class SupportTicketRepository {
  Future<List<SupportTicket>> getMyTickets();

  Future<SupportTicket> createTicket({
    required String subject,
    required SupportTicketCategory category,
    required String message,
    SupportTicketPriority priority = SupportTicketPriority.medium,
    int? orderId,
    int? deliveryId,
  });

  Future<List<SupportMessage>> getTicketMessages(int ticketId);

  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  });
}

class InMemorySupportTicketRepository implements SupportTicketRepository {
  InMemorySupportTicketRepository({
    List<SupportTicket>? seedTickets,
    Map<int, List<SupportMessage>>? seedMessages,
  }) : _tickets = [...?seedTickets],
       _messagesByTicket = {
         if (seedMessages != null)
           for (final entry in seedMessages.entries)
             entry.key: [...entry.value],
       };

  final List<SupportTicket> _tickets;
  final Map<int, List<SupportMessage>> _messagesByTicket;
  int _nextTicketId = 1000;
  int _nextMessageId = 5000;

  @override
  Future<List<SupportTicket>> getMyTickets() async {
    _tickets.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return List.unmodifiable(_tickets);
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
    final now = DateTime.now();
    final ticketId = ++_nextTicketId;
    final randomPart = Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
    final ticketNumber = 'TCK-$randomPart';

    final ticket = SupportTicket(
      ticketId: ticketId,
      ticketNumber: ticketNumber,
      subject: subject.trim(),
      category: category,
      status: SupportTicketStatus.open,
      priority: priority,
      createdAt: now,
      updatedAt: now,
      lastMessage: message.trim(),
      orderId: orderId,
      deliveryId: deliveryId,
    );

    final initialMsg = SupportMessage(
      messageId: ++_nextMessageId,
      ticketId: ticketId,
      senderRole: SupportMessageSenderRole.user,
      senderName: 'You',
      body: message.trim(),
      createdAt: now,
    );

    _tickets.insert(0, ticket);
    _messagesByTicket[ticketId] = [initialMsg];

    return ticket;
  }

  @override
  Future<List<SupportMessage>> getTicketMessages(int ticketId) async {
    final msgs = _messagesByTicket[ticketId] ?? [];
    msgs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(msgs);
  }

  @override
  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  }) async {
    final now = DateTime.now();
    final msg = SupportMessage(
      messageId: ++_nextMessageId,
      ticketId: ticketId,
      senderRole: SupportMessageSenderRole.user,
      senderName: 'You',
      body: body.trim(),
      createdAt: now,
    );

    final msgs = _messagesByTicket.putIfAbsent(ticketId, () => []);
    msgs.add(msg);

    // Update ticket: Re-open if resolved or closed, and update last_message
    final idx = _tickets.indexWhere((t) => t.ticketId == ticketId);
    if (idx != -1) {
      final existing = _tickets[idx];
      _tickets[idx] = existing.copyWith(
        status: existing.status.isTerminal
            ? SupportTicketStatus.open
            : existing.status,
        lastMessage: body.trim(),
        updatedAt: now,
      );
    }

    return msg;
  }
}
