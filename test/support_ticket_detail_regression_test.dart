import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_ticket_detail_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/utils/support_date_time_formatter.dart';

final ticket = SupportTicket(
  ticketId: 7,
  ticketNumber: 'TCK-000007',
  subject: 'Payment question',
  category: SupportTicketCategory.payment,
  status: SupportTicketStatus.closed,
  priority: SupportTicketPriority.high,
  createdAt: DateTime(2026, 10, 1, 9, 5),
  updatedAt: DateTime(2026, 10, 1, 9, 5),
  resolutionNotes: 'Payment confirmed',
);

SupportMessage message(SupportMessageSenderRole role) => SupportMessage(
  messageId: role.index,
  ticketId: ticket.ticketId,
  senderRole: role,
  senderName: '${role.name} sender',
  body: '${role.name} message',
  createdAt: ticket.createdAt,
);

class DetailRepository extends InMemorySupportTicketRepository {
  DetailRepository()
    : super(
        seedTickets: [ticket],
        seedMessages: {
          7: SupportMessageSenderRole.values.map(message).toList(),
        },
      );
  Completer<List<SupportMessage>>? pendingLoad;
  Completer<SupportMessage>? pendingSend;
  int loads = 0;
  int sends = 0;

  @override
  Future<List<SupportMessage>> getTicketMessages(int ticketId) {
    loads++;
    return pendingLoad?.future ?? super.getTicketMessages(ticketId);
  }

  @override
  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  }) {
    sends++;
    return pendingSend?.future ??
        super.sendMessage(ticketId: ticketId, body: body);
  }
}

Future<void> openDetail(
  WidgetTester tester,
  DetailRepository repository, {
  SupportTicketDetailController? controller,
  SupportTicketsController? ticketsController,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SupportTicketDetailScreen(
        ticket: ticket,
        repository: repository,
        detailController: controller,
        ticketsController: ticketsController,
      ),
    ),
  );
}

void main() {
  test('date formatting retains date order and padded time', () {
    expect(formatSupportDateTime(ticket.createdAt), '10/1/2026 09:05');
  });

  testWidgets(
    'header and all message roles retain content and sender visibility',
    (tester) async {
      await openDetail(tester, DetailRepository());
      await tester.pumpAndSettle();
      expect(find.text('TCK-000007'), findsOneWidget);
      expect(find.text('Payment & Refund'), findsOneWidget);
      expect(find.text('Closed'), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
      expect(find.text('Resolution Notes: Payment confirmed'), findsOneWidget);
      expect(find.text('Created on 10/1/2026 09:05'), findsOneWidget);
      for (final role in SupportMessageSenderRole.values) {
        expect(find.text('${role.name} message'), findsOneWidget);
      }
      expect(find.text('support sender'), findsOneWidget);
      expect(find.text('user sender'), findsNothing);
      expect(find.text('system sender'), findsNothing);
      expect(find.byIcon(Icons.support_agent_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loading failure offers retry and refresh reloads the thread', (
    tester,
  ) async {
    final repository = DetailRepository()
      ..pendingLoad = Completer<List<SupportMessage>>();
    await openDetail(tester, repository);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.pendingLoad!.completeError(StateError('Unavailable'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not load messages. Please try again.'),
      findsOneWidget,
    );
    repository.pendingLoad = null;
    await tester.tap(find.text('Try Again'));
    await tester.pumpAndSettle();
    expect(find.text('support message'), findsOneWidget);
    expect(repository.loads, 2);
    await tester.tap(find.byTooltip('Refresh Thread'));
    await tester.pumpAndSettle();
    expect(repository.loads, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'failed reply clears input, disables send while pending, and shows feedback',
    (tester) async {
      final repository = DetailRepository()
        ..pendingSend = Completer<SupportMessage>();
      await openDetail(tester, repository);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), ' Retry payment ');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final send = find.byWidgetPredicate(
        (widget) => widget is IconButton && widget.icon is SizedBox,
      );
      expect(tester.widget<IconButton>(send).onPressed, isNull);
      repository.pendingSend!.completeError(StateError('Unavailable'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not send your message. Please try again.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      expect(repository.sends, 1);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'composer submission reopens the ticket and updates the ticket list',
    (tester) async {
      final repository = DetailRepository();
      final tickets = SupportTicketsController(repository: repository);
      addTearDown(tickets.dispose);
      await tickets.loadTickets();
      await openDetail(tester, repository, ticketsController: tickets);
      await tester.pumpAndSettle();
      expect(
        find.text('Replying will automatically re-open this ticket.'),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), ' One more question ');
      tester.widget<TextField>(find.byType(TextField)).onSubmitted!('ignored');
      await tester.pumpAndSettle();
      expect(find.text('One more question'), findsOneWidget);
      expect(find.text('Open'), findsOneWidget);
      expect(
        find.text('Replying will automatically re-open this ticket.'),
        findsNothing,
      );
      expect(tickets.tickets.single.status, SupportTicketStatus.open);
      expect(tickets.tickets.single.lastMessage, 'One more question');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'screen leaves an injected detail controller usable after disposal',
    (tester) async {
      final repository = DetailRepository();
      final controller = SupportTicketDetailController(
        ticket: ticket,
        repository: repository,
      );
      addTearDown(controller.dispose);
      await openDetail(tester, repository, controller: controller);
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await controller.loadMessages();
      expect(controller.messages.length, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
