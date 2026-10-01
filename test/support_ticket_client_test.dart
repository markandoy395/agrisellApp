import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_ticket_detail_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/create_support_ticket_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/widgets/support_ticket_card.dart';

void main() {
  group('SupportTicket Domain & Models', () {
    test('SupportTicket serialization and deserialization', () {
      final now = DateTime(2026, 9, 21, 10, 30);
      final json = {
        'ticket_id': 42,
        'ticket_number': 'TCK-ABC123',
        'subject': 'Damaged package received',
        'category': 'delivery',
        'status': 'in_progress',
        'priority': 'high',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'last_message': 'Checking with rider.',
        'user_role': 'buyer',
        'assigned_admin': 'Admin Sarah',
        'resolution_notes': null,
        'order_id': 101,
        'delivery_id': 202,
      };

      final ticket = SupportTicket.fromJson(json);
      expect(ticket.ticketId, 42);
      expect(ticket.ticketNumber, 'TCK-ABC123');
      expect(ticket.subject, 'Damaged package received');
      expect(ticket.category, SupportTicketCategory.delivery);
      expect(ticket.status, SupportTicketStatus.inProgress);
      expect(ticket.priority, SupportTicketPriority.high);
      expect(ticket.status.isOpen, isTrue);
      expect(ticket.status.isTerminal, isFalse);
      expect(ticket.lastMessage, 'Checking with rider.');
      expect(ticket.orderId, 101);
      expect(ticket.deliveryId, 202);

      final exportedJson = ticket.toJson();
      expect(exportedJson['ticket_id'], 42);
      expect(exportedJson['category'], 'delivery');
      expect(exportedJson['status'], 'in_progress');
      expect(exportedJson['priority'], 'high');
    });

    test('SupportMessage serialization and role classification', () {
      final now = DateTime(2026, 9, 21, 10, 35);
      final userMsgJson = {
        'message_id': 1,
        'ticket_id': 42,
        'sender_role': 'user',
        'sender_name': 'Buyer John',
        'body': 'Items arrived crushed.',
        'created_at': now.toIso8601String(),
      };

      final userMsg = SupportMessage.fromJson(userMsgJson);
      expect(userMsg.senderRole.isFromCustomer, isTrue);
      expect(userMsg.senderRole.isFromSupport, isFalse);
      expect(userMsg.body, 'Items arrived crushed.');

      final supportMsgJson = {
        'message_id': 2,
        'ticket_id': 42,
        'sender_role': 'support',
        'sender_name': 'Agrisell Support',
        'body': 'We have processed your refund.',
        'created_at': now.toIso8601String(),
      };

      final supportMsg = SupportMessage.fromJson(supportMsgJson);
      expect(supportMsg.senderRole.isFromSupport, isTrue);
      expect(supportMsg.senderRole.isFromCustomer, isFalse);
    });

    test('Category and priority enums fallback gracefully to defaults', () {
      expect(SupportTicketCategory.fromDb('unknown_cat'), SupportTicketCategory.general);
      expect(SupportTicketPriority.fromDb('crazy_priority'), SupportTicketPriority.medium);
      expect(SupportTicketStatus.fromDb('unrecognized'), SupportTicketStatus.open);
    });
  });

  group('InMemorySupportTicketRepository', () {
    late InMemorySupportTicketRepository repository;

    setUp(() {
      repository = InMemorySupportTicketRepository();
    });

    test('creates ticket and initial message, sets status open', () async {
      final ticket = await repository.createTicket(
        subject: 'Cannot login to account',
        category: SupportTicketCategory.account,
        message: 'Password reset email is not arriving.',
        priority: SupportTicketPriority.urgent,
      );

      expect(ticket.ticketId, isPositive);
      expect(ticket.ticketNumber, startsWith('TCK-'));
      expect(ticket.subject, 'Cannot login to account');
      expect(ticket.category, SupportTicketCategory.account);
      expect(ticket.priority, SupportTicketPriority.urgent);
      expect(ticket.status, SupportTicketStatus.open);

      final myTickets = await repository.getMyTickets();
      expect(myTickets.length, 1);
      expect(myTickets.first.ticketId, ticket.ticketId);

      final messages = await repository.getTicketMessages(ticket.ticketId);
      expect(messages.length, 1);
      expect(messages.first.body, 'Password reset email is not arriving.');
      expect(messages.first.senderRole, SupportMessageSenderRole.user);
    });

    test('sending reply re-opens resolved ticket to open status', () async {
      final resolvedTicket = SupportTicket(
        ticketId: 77,
        ticketNumber: 'TCK-000077',
        subject: 'Wrong weight delivered',
        category: SupportTicketCategory.order,
        status: SupportTicketStatus.resolved,
        priority: SupportTicketPriority.medium,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        lastMessage: 'Your refund has been approved.',
      );

      final repo = InMemorySupportTicketRepository(
        seedTickets: [resolvedTicket],
      );

      var current = (await repo.getMyTickets()).first;
      expect(current.status, SupportTicketStatus.resolved);

      // Customer sends reply
      final reply = await repo.sendMessage(
        ticketId: 77,
        body: 'Wait, I still have a question about the invoice.',
      );

      expect(reply.body, 'Wait, I still have a question about the invoice.');

      // Ticket must now be re-opened to 'open'
      current = (await repo.getMyTickets()).first;
      expect(current.status, SupportTicketStatus.open);
      expect(current.lastMessage, 'Wait, I still have a question about the invoice.');
    });
  });

  group('Controllers', () {
    test('missing support schema shows a customer-friendly error', () async {
      final controller = SupportTicketsController(
        repository: _MissingSchemaSupportTicketRepository(),
      );

      await controller.loadTickets();

      expect(controller.tickets, isEmpty);
      expect(
        controller.errorMessage,
        'Customer support is temporarily unavailable. Please try again later.',
      );
      controller.dispose();
    });

    test('SupportTicketsController loads and filters tickets', () async {
      final repository = InMemorySupportTicketRepository(
        seedTickets: [
          SupportTicket(
            ticketId: 1,
            ticketNumber: 'TCK-000001',
            subject: 'Safety incident on highway',
            category: SupportTicketCategory.safety,
            status: SupportTicketStatus.open,
            priority: SupportTicketPriority.urgent,
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
            lastMessage: 'Assistance needed.',
          ),
          SupportTicket(
            ticketId: 2,
            ticketNumber: 'TCK-000002',
            subject: 'Payment receipt inquiry',
            category: SupportTicketCategory.payment,
            status: SupportTicketStatus.resolved,
            priority: SupportTicketPriority.low,
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
            lastMessage: 'Receipt sent.',
          ),
        ],
      );

      final controller = SupportTicketsController(repository: repository);
      await controller.loadTickets();

      expect(controller.tickets.length, 2);
      expect(controller.filteredTickets.length, 2);

      // Filter: open
      controller.setFilter('open');
      expect(controller.filteredTickets.length, 1);
      expect(controller.filteredTickets.first.ticketId, 1);

      // Filter: resolved
      controller.setFilter('resolved');
      expect(controller.filteredTickets.length, 1);
      expect(controller.filteredTickets.first.ticketId, 2);

      // Search keyword
      controller.setFilter('all');
      controller.setSearch('safety');
      expect(controller.filteredTickets.length, 1);
      expect(controller.filteredTickets.first.category, SupportTicketCategory.safety);

      controller.setSearch('non-existent');
      expect(controller.filteredTickets.isEmpty, isTrue);

      controller.dispose();
    });

    test('SupportTicketDetailController loads messages and sends reply', () async {
      final ticket = SupportTicket(
        ticketId: 5,
        ticketNumber: 'TCK-000005',
        subject: 'Damaged item',
        category: SupportTicketCategory.order,
        status: SupportTicketStatus.open,
        priority: SupportTicketPriority.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = InMemorySupportTicketRepository(
        seedTickets: [ticket],
        seedMessages: {
          5: [
            SupportMessage(
              messageId: 10,
              ticketId: 5,
              senderRole: SupportMessageSenderRole.user,
              senderName: 'Customer',
              body: 'My produce arrived damaged.',
              createdAt: DateTime.now(),
            ),
          ],
        },
      );

      final detailController = SupportTicketDetailController(
        ticket: ticket,
        repository: repository,
      );

      await detailController.loadMessages();
      expect(detailController.messages.length, 1);

      final sent = await detailController.sendMessage('Here is additional information.');
      expect(sent, isTrue);
      expect(detailController.messages.length, 2);
      expect(detailController.messages.last.body, 'Here is additional information.');

      detailController.dispose();
    });
  });

  group('Widget Tests', () {
    testWidgets('SupportCenterScreen hides database details when unavailable', (
      tester,
    ) async {
      final controller = SupportTicketsController(
        repository: _MissingSchemaSupportTicketRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(home: SupportCenterScreen(controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Customer support is temporarily unavailable. Please try again later.',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('PostgrestException'), findsNothing);
      expect(find.textContaining('public.support_tickets'), findsNothing);
      controller.dispose();
    });

    testWidgets('SupportCenterScreen displays tickets and filter chips', (tester) async {
      final repository = InMemorySupportTicketRepository(
        seedTickets: [
          SupportTicket(
            ticketId: 10,
            ticketNumber: 'TCK-101010',
            subject: 'Delivery delayed past schedule',
            category: SupportTicketCategory.delivery,
            status: SupportTicketStatus.open,
            priority: SupportTicketPriority.high,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            lastMessage: 'Looking into the assigned rider.',
          ),
        ],
      );

      final controller = SupportTicketsController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: SupportCenterScreen(controller: controller),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Customer Support'), findsOneWidget);
      expect(find.text('Delivery delayed past schedule'), findsOneWidget);
      expect(find.text('TCK-101010'), findsOneWidget);
      expect(find.byType(SupportTicketCard), findsOneWidget);
      expect(find.text('Open Ticket'), findsOneWidget);
    });

    testWidgets('CreateSupportTicketScreen validates and submits new ticket', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final repository = InMemorySupportTicketRepository();
      final controller = SupportTicketsController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: CreateSupportTicketScreen(
            controller: controller,
            initialCategory: SupportTicketCategory.safety,
            initialPriority: SupportTicketPriority.urgent,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Open Support Ticket'), findsOneWidget);

      // Try submitting without entering text
      await tester.ensureVisible(find.text('Submit Support Ticket'));
      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pumpAndSettle();

      expect(find.text('Subject must be at least 2 characters long.'), findsOneWidget);

      // Enter subject and message
      await tester.enterText(
        find.byType(TextFormField).first,
        'Urgent safety concern at pickup',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Dangerous road conditions near the warehouse gate.',
      );
      await tester.pumpAndSettle();

      // Submit
      await tester.ensureVisible(find.text('Submit Support Ticket'));
      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pumpAndSettle();

      final tickets = await repository.getMyTickets();
      expect(tickets.length, 1);
      expect(tickets.first.subject, 'Urgent safety concern at pickup');
      expect(tickets.first.category, SupportTicketCategory.safety);
      expect(tickets.first.priority, SupportTicketPriority.urgent);
    });

    testWidgets('SupportTicketDetailScreen displays thread and composer', (tester) async {
      final ticket = SupportTicket(
        ticketId: 20,
        ticketNumber: 'TCK-202020',
        subject: 'Payment verification issue',
        category: SupportTicketCategory.payment,
        status: SupportTicketStatus.open,
        priority: SupportTicketPriority.medium,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = InMemorySupportTicketRepository(
        seedTickets: [ticket],
        seedMessages: {
          20: [
            SupportMessage(
              messageId: 100,
              ticketId: 20,
              senderRole: SupportMessageSenderRole.user,
              senderName: 'You',
              body: 'I paid via GCash but reference is pending.',
              createdAt: DateTime.now(),
            ),
            SupportMessage(
              messageId: 101,
              ticketId: 20,
              senderRole: SupportMessageSenderRole.support,
              senderName: 'Support Agent Dave',
              body: 'We are verifying with our payment gateway.',
              createdAt: DateTime.now(),
            ),
          ],
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SupportTicketDetailScreen(
            ticket: ticket,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('TCK-202020'), findsOneWidget);
      expect(find.text('Payment verification issue'), findsOneWidget);
      expect(find.text('I paid via GCash but reference is pending.'), findsOneWidget);
      expect(find.text('We are verifying with our payment gateway.'), findsOneWidget);
      expect(find.text('Support Agent Dave'), findsOneWidget);

      // Send a follow-up reply
      await tester.enterText(find.byType(TextField), 'Thank you, please expedite.');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Thank you, please expedite.'), findsOneWidget);

      final messages = await repository.getTicketMessages(20);
      expect(messages.length, 3);
      expect(messages.last.body, 'Thank you, please expedite.');
    });
  });
}

class _MissingSchemaSupportTicketRepository
    extends InMemorySupportTicketRepository {
  @override
  Future<List<SupportTicket>> getMyTickets() async {
    throw const PostgrestException(
      message: "Could not find the table 'public.support_tickets'",
      code: 'PGRST205',
    );
  }
}
