import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/support/data/support_ticket_repository.dart';
import 'package:agresell_app/features/shared/support/domain/support_ticket.dart';
import 'package:agresell_app/features/shared/support/domain/support_message.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_tickets_controller.dart';
import 'package:agresell_app/features/shared/support/presentation/controllers/support_ticket_detail_controller.dart';
import 'package:agresell_app/features/shared/chat/presentation/controllers/marketplace_messaging_controller.dart';
import 'package:agresell_app/features/shared/chat/domain/marketplace_conversation.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'support/marketplace_messaging_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final role in ['buyer', 'farmer', 'rider']) {
    test(
      '$role support blocks duplicate sends and discards stale loads',
      () async {
        final repo = ControlledSupport();
        final ticket = await repo.seed();
        final controller = SupportTicketDetailController(
          ticket: ticket,
          repository: repo,
        );
        addTearDown(controller.dispose);
        repo.loadGate = Completer<List<SupportMessage>>();
        final load = controller.loadMessages();
        final send = controller.sendMessage('Help');
        expect(await controller.sendMessage('Help'), isFalse);
        repo.sendGate.complete();
        expect(await send, isTrue);
        repo.loadGate!.complete([]);
        await load;
        expect(controller.messages, hasLength(1));
        expect(repo.sends, 1);
      },
    );
  }

  test(
    'support creation blocks repeat submissions and survives disposal',
    () async {
      final repo = ControlledSupport()..createGate = Completer<void>();
      final controller = SupportTicketsController(repository: repo);
      final first = controller.createTicket(
        subject: 'Help',
        category: SupportTicketCategory.general,
        message: 'Hello',
      );
      expect(
        await controller.createTicket(
          subject: 'Help',
          category: SupportTicketCategory.general,
          message: 'Hello',
        ),
        isNull,
      );
      controller.dispose();
      repo.createGate!.complete();
      expect(await first, isNull);
      expect(repo.creates, 1);
    },
  );

  for (final role in MarketplaceActorRole.values) {
    test(
      '$role chat ignores an old message read after a confirmed send',
      () async {
        final repo = ControlledMessages();
        final controller = MarketplaceMessagingController(
          repository: repo,
          actorRole: role,
        );
        addTearDown(controller.dispose);
        await controller.load();
        final opening = controller.openConversation('12');
        expect(await controller.sendMessage('12', 'New message'), isTrue);
        repo.oldRead.complete([]);
        await opening;
        expect(
          controller.messagesFor('12').any((m) => m.text == 'New message'),
          isTrue,
        );
      },
    );
  }

  test(
    'rider ratings discard older results and results after disposal',
    () async {
      final repo = ControlledAnalytics();
      final controller = RiderAnalyticsController(repository: repo);
      final old = controller.loadRatings(riderId: 'old');
      final latest = controller.loadRatings(riderId: 'latest');
      final fresh = RiderRatingsData.empty();
      repo.reads['latest']!.complete(fresh);
      await latest;
      repo.reads['old']!.completeError(StateError('late failure'));
      await old;
      expect(controller.ratingsState, RiderAnalyticsLoadState.ready);
      expect(controller.ratings, same(fresh));
      final pending = controller.loadRatings(riderId: 'closed');
      controller.dispose();
      repo.reads['closed']!.complete(fresh);
      await pending;
    },
  );
}

class ControlledSupport extends InMemorySupportTicketRepository {
  final sendGate = Completer<void>();
  Completer<void>? createGate;
  Completer<List<SupportMessage>>? loadGate;
  int sends = 0;
  int creates = 0;
  Future<SupportTicket> seed() => super.createTicket(
    subject: 'Help',
    category: SupportTicketCategory.general,
    message: 'Hello',
  );
  @override
  Future<SupportTicket> createTicket({
    required String subject,
    required SupportTicketCategory category,
    required String message,
    SupportTicketPriority priority = SupportTicketPriority.medium,
    int? orderId,
    int? deliveryId,
  }) async {
    creates++;
    if (createGate != null) await createGate!.future;
    return super.createTicket(
      subject: subject,
      category: category,
      message: message,
      priority: priority,
    );
  }

  @override
  Future<List<SupportMessage>> getTicketMessages(int ticketId) =>
      loadGate?.future ?? super.getTicketMessages(ticketId);
  @override
  Future<SupportMessage> sendMessage({
    required int ticketId,
    required String body,
  }) async {
    sends++;
    await sendGate.future;
    return super.sendMessage(ticketId: ticketId, body: body);
  }
}

class ControlledMessages extends FakeMarketplaceMessagingRepository {
  final oldRead = Completer<List<MarketplaceMessage>>();
  int reads = 0;
  @override
  Future<List<MarketplaceMessage>> loadMessages(String conversationId) {
    if (reads++ == 0) return oldRead.future;
    return super.loadMessages(conversationId);
  }
}

class ControlledAnalytics extends InMemoryRiderAnalyticsRepository {
  final reads = <String, Completer<RiderRatingsData>>{};
  @override
  Future<RiderRatingsData> fetchRatings({required String riderId}) =>
      (reads[riderId] = Completer<RiderRatingsData>()).future;
}
