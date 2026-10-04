import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/create_support_ticket_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_ticket_detail_screen.dart';
import 'support/authenticated_test_session.dart';

void main() {
  configureAuthenticatedTests();
  for (final size in [320.0, 430.0]) {
    testWidgets('ticket form selections and counter fit width $size', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(size, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final controller = SupportTicketsController(
        repository: InMemorySupportTicketRepository(),
      );
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(home: CreateSupportTicketScreen(controller: controller)),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Select the category that best matches your issue.'),
        findsOneWidget,
      );
      final order = tester.getRect(find.text('Order Issue'));
      final delivery = tester.getRect(find.text('Delivery Problem'));
      expect(order.left, lessThan(delivery.left));
      await tester.ensureVisible(find.text('Safety & Security'));
      await tester.tap(find.text('Safety & Security'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Semantics>(
              find.byWidgetPredicate(
                (w) =>
                    w is Semantics && w.properties.label == 'Safety & Security',
              ),
            )
            .properties
            .selected,
        isTrue,
      );
      await tester.ensureVisible(find.text('Urgent'));
      await tester.tap(find.text('Urgent'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Semantics>(
              find.byWidgetPredicate(
                (w) => w is Semantics && w.properties.label == 'Urgent',
              ),
            )
            .properties
            .selected,
        isTrue,
      );
      await tester.ensureVisible(find.byType(TextField).last);
      expect(find.text('0/4000'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, 'Need help');
      await tester.pump();
      expect(find.text('9/4000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets(
    'validation and submission preserve selected category and priority',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = InMemorySupportTicketRepository();
      final controller = SupportTicketsController(repository: repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: CreateSupportTicketScreen(
            controller: controller,
            initialCategory: SupportTicketCategory.safety,
            initialPriority: SupportTicketPriority.medium,
          ),
        ),
      );
      await tester.ensureVisible(find.text('Submit Support Ticket'));
      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pumpAndSettle();
      expect(
        find.text('Subject must be at least 2 characters long.'),
        findsOneWidget,
      );
      expect(
        find.text('Please describe your inquiry or issue.'),
        findsOneWidget,
      );
      expect(await repository.getMyTickets(), isEmpty);
      await tester.ensureVisible(find.byType(TextField).first);
      await tester.enterText(find.byType(TextField).first, 'Pickup concern');
      await tester.enterText(
        find.byType(TextField).last,
        'Please help with the pickup location.',
      );
      await tester.ensureVisible(find.text('Submit Support Ticket'));
      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pumpAndSettle();
      final ticket = (await repository.getMyTickets()).single;
      expect(ticket.subject, 'Pickup concern');
      expect(ticket.category, SupportTicketCategory.safety);
      expect(ticket.priority, SupportTicketPriority.medium);
      expect(find.byType(SupportTicketDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
