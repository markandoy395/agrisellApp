import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/chat/data/rider_message_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_models.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_conversation_access.dart';
import 'package:agresell_app/features/rider/chat/presentation/controllers/rider_messages_controller.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'offline locations are chronological, deduplicated, and acknowledged',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final first = _location(DateTime.utc(2030, 1, 1, 10));
      final second = _location(DateTime.utc(2030, 1, 1, 10, 1), latitude: 8.5);
      final outbox = RiderLocationOutbox(preferences: preferences);
      await outbox.record(second);
      await outbox.record(first);
      await outbox.record(first);
      expect(
        (await outbox.loadPending()).map((item) => item.capturedAt.toUtc()),
        [first.capturedAt.toUtc(), second.capturedAt.toUtc()],
      );
      final remote = _LocationRemote();
      final restored = RiderLocationOutbox(
        preferences: preferences,
        remote: remote,
      );
      expect(await restored.sync(), isTrue);
      expect(remote.sent.map((item) => item.capturedAt.toUtc()), [
        first.capturedAt.toUtc(),
        second.capturedAt.toUtc(),
      ]);
      expect(await restored.loadPending(), isEmpty);
    },
  );

  test('offline chat message is durable and marked pending', () async {
    const access = RiderConversationAccess(activeDeliveryIds: {'delivery-1'});
    final conversation = RiderConversation(
      id: 'chat-1',
      participantLabel: 'Buyer',
      party: RiderConversationParty.buyer,
      deliveryId: 'delivery-1',
    );
    final queue = RiderOfflineActionQueue(
      clock: () => DateTime.utc(2030, 1, 1),
    );
    final controller = RiderMessagesController(
      repository: _OfflineMessageRepository(conversation, access),
      offlineQueue: queue,
    );
    addTearDown(controller.dispose);
    await controller.load(riderId: 'rider-1', access: access);
    await controller.selectConversation(conversation);
    controller.setBackendReachable(false);
    expect(await controller.send('I am on my way.'), isTrue);
    expect(queue.actions.single.type, OfflineDeliveryActionType.message);
    expect(controller.messages.single.isPending, isTrue);
  });
}

RiderLocationUpdate _location(DateTime at, {double latitude = 8.48}) =>
    RiderLocationUpdate(
      latitude: latitude,
      longitude: 124.65,
      accuracyMeters: 8,
      capturedAt: at,
      riderId: 'rider-1',
      deliveryId: 'delivery-1',
    );

class _LocationRemote implements RiderLocationRemoteDataSource {
  final List<RiderLocationUpdate> sent = [];

  @override
  Future<void> send(RiderLocationUpdate update) async => sent.add(update);
}

class _OfflineMessageRepository extends InMemoryRiderMessageRepository {
  _OfflineMessageRepository(
    RiderConversation conversation,
    RiderConversationAccess access,
  ) : super(conversations: [conversation], access: access);

  @override
  Future<RiderChatMessage> sendMessage({
    required String riderId,
    required RiderMessageDraft draft,
  }) => throw const RiderMessageRepositoryException(
    'No connection.',
    isOffline: true,
  );
}
