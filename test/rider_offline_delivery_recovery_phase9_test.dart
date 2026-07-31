import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/data/shared_preferences_rider_delivery_state_store.dart';
import 'package:agresell_app/features/rider/deliveries/data/shared_preferences_rider_offline_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_offline_sync_banner.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

part 'rider_offline_delivery_recovery_phase9_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'offline status survives restart and reconciles once on reconnection',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final stateStore = SharedPreferencesRiderDeliveryStateStore(
        preferences: preferences,
      );
      final repository = InMemoryRiderDeliveryRepository(
        requests: [_request()],
      );
      final first = RiderDeliveryController(
        repository: repository,
        stateStore: stateStore,
        offlineQueue: _queue(preferences),
      );
      first.updateProfile(_profile());
      await first.applyAuthoritativeAvailability(
        RiderAvailability.deliveryReserved,
        loadRequests: false,
      );
      await first.load(riderId: 'rider-1');
      first.setBackendReachable(false);
      final result = await first.updateStatus(
        deliveryId: 'delivery-1',
        riderId: 'rider-1',
        newStatus: DeliveryStatus.goingToPickup,
      );
      await first.saveRecoveryData('deliveryConfirmation:delivery-1', {
        'recipientName': 'Buyer',
      });
      expect(result.isSuccess, isTrue);
      first.dispose();

      final restored = RiderDeliveryController(
        repository: repository,
        stateStore: stateStore,
        offlineQueue: _queue(preferences),
      );
      addTearDown(restored.dispose);
      restored.updateProfile(_profile());
      expect(await restored.restore(riderId: 'rider-1'), isTrue);
      expect(restored.offlineActions, hasLength(1));
      expect(
        restored.recoveryDataFor(
          'deliveryConfirmation:delivery-1',
        )['recipientName'],
        'Buyer',
      );

      restored.setBackendReachable(true);
      await restored.synchronizeOfflineActions();
      expect(restored.offlineActions, isEmpty);
      expect(restored.activeDeliveryStatus, DeliveryStatus.goingToPickup);
    },
  );

  test(
    'offline delivery proof keeps active delivery and queues secure evidence',
    () async {
      final controller = RiderDeliveryController(
        repository: InMemoryRiderDeliveryRepository(
          requests: [_request(stage: DeliveryStage.arrivedAtDelivery)],
        ),
      );
      addTearDown(controller.dispose);
      controller.updateProfile(_profile());
      await controller.applyAuthoritativeAvailability(
        RiderAvailability.waitingAtDeliveryLocation,
        loadRequests: false,
      );
      await controller.load(riderId: 'rider-1');
      controller.setBackendReachable(false);

      final result = await controller.completeDelivery(
        command: DeliveryCompletionCommand(
          deliveryId: 'delivery-1',
          riderId: 'rider-1',
          idempotencyKey: 'proof-1',
          finalLocation: _location(),
          proofReferences: const {},
        ),
      );

      expect(result.isSuccess, isFalse);
      expect(controller.hasActiveDelivery, isTrue);
      expect(
        controller.offlineActions.single.type,
        OfflineDeliveryActionType.deliveryProof,
      );
    },
  );

  test('offline delivery acceptance is blocked', () async {
    final controller = RiderDeliveryController(
      repository: InMemoryRiderDeliveryRepository(
        requests: [_request(stage: DeliveryStage.readyForPickup)],
      ),
    );
    addTearDown(controller.dispose);
    controller.updateProfile(_profile());
    controller.setOnline(true);
    await controller.load(riderId: 'rider-1');
    controller.setBackendReachable(false);

    final result = await controller.accept(
      requestId: 'delivery-1',
      riderId: 'rider-1',
    );

    expect(result.isSuccess, isFalse);
  });

  testWidgets('sync banner exposes waiting synchronization state', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final queue = _queue(preferences);
    await queue.initialize('rider-1');
    await queue.add(
      riderId: 'rider-1',
      deliveryId: 'delivery-1',
      type: OfflineDeliveryActionType.riderNote,
      payload: const {'note': 'Gate closed'},
      originalTimestamp: DateTime.utc(2030),
    );
    final controller = RiderDeliveryController(offlineQueue: queue);
    addTearDown(controller.dispose);
    controller.setBackendReachable(false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RiderOfflineSyncBanner(controller: controller)),
      ),
    );

    expect(find.text('Waiting to synchronize'), findsOneWidget);
  });
}
