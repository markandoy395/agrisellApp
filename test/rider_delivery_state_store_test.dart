import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/shared_preferences_rider_delivery_state_store.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_state_snapshot.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'support/rider_batch_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('availability and active summary persist with rider scope', () async {
    final store = SharedPreferencesRiderDeliveryStateStore(
      preferences: await SharedPreferences.getInstance(),
    );
    final deadline = DateTime.utc(2030, 1, 2);
    final event = DeliveryStatusEvent(
      eventId: 'event-1',
      deliveryId: 'delivery-1',
      previousStatus: DeliveryStatus.arrivedAtPickup,
      newStatus: DeliveryStatus.waitingForProduct,
      riderId: 'rider-a',
      timestamp: DateTime.utc(2030, 1, 1),
      source: DeliveryEventSource.online,
      syncStatus: DeliveryEventSyncStatus.synchronized,
    );
    final snapshot = RiderDeliveryStateSnapshot(
      availability: RiderAvailability.waitingAtPickup,
      activeDeliveryId: 'delivery-1',
      currentDeliveryStatus: DeliveryStatus.waitingForProduct,
      activeDeliverySummary: ActiveDeliverySummary(
        deliveryId: 'delivery-1',
        orderNumber: 'ORD-1',
        productName: 'Vegetables',
        sellerName: 'Seller',
        buyerName: 'Buyer',
        pickupAddress: 'Farm',
        destinationAddress: 'Market',
        pickupDeadline: deadline,
        deliveryFee: 95,
      ),
      statusEvents: [event],
      pendingOfflineActionCount: 3,
      lastSynchronizationTime: DateTime.utc(2030, 1, 1),
    );

    await store.save('rider-a', snapshot);
    final restored = await store.load('rider-a');

    expect(restored?.availability, RiderAvailability.waitingAtPickup);
    expect(restored?.activeDeliveryId, 'delivery-1');
    expect(restored?.currentDeliveryStatus, DeliveryStatus.waitingForProduct);
    expect(restored?.activeDeliverySummary?.pickupDeadline, deadline.toLocal());
    expect(restored?.pendingOfflineActionCount, 3);
    expect(
      restored?.statusEvents.single.newStatus,
      DeliveryStatus.waitingForProduct,
    );
    expect(await store.load('rider-b'), isNull);
  });

  test('controller restores accepted delivery after recreation', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesRiderDeliveryStateStore(
      preferences: preferences,
    );
    final repository = InMemoryRiderDeliveryRepository(
      requests: [_activeRequest()],
    );
    final first = RiderDeliveryController(
      repository: repository,
      stateStore: store,
    );
    first.updateProfile(_verifiedProfile());
    await first.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await first.load(riderId: 'rider-a');
    first.dispose();

    final recreated = RiderDeliveryController(
      repository: repository,
      stateStore: store,
    );
    addTearDown(recreated.dispose);
    recreated.updateProfile(_verifiedProfile());

    expect(await recreated.restore(riderId: 'rider-a'), isTrue);
    expect(recreated.status.availability, RiderAvailability.deliveryReserved);
    expect(recreated.requests.single.id, 'delivery-1');
    expect(recreated.requests.single.stage, DeliveryStage.accepted);
    expect(recreated.lastSynchronizationTime, isNotNull);
  });

  test('controller restores every delivery in an active batch', () async {
    final store = SharedPreferencesRiderDeliveryStateStore(
      preferences: await SharedPreferences.getInstance(),
    );
    final repository = InMemoryRiderDeliveryRepository(
      requests: [
        batchRequest(
          id: 'batch-a',
          stage: DeliveryStage.accepted,
          assignedRiderId: 'rider-a',
        ),
        batchRequest(
          id: 'batch-b',
          stage: DeliveryStage.accepted,
          assignedRiderId: 'rider-a',
        ),
      ],
    );
    final first = RiderDeliveryController(
      repository: repository,
      stateStore: store,
    )..updateProfile(batchRiderProfile());
    await first.applyAuthoritativeAvailability(
      RiderAvailability.deliveryReserved,
      loadRequests: false,
    );
    await first.load(riderId: 'rider-a');
    first.dispose();

    final restored = RiderDeliveryController(
      repository: repository,
      stateStore: store,
    )..updateProfile(batchRiderProfile());
    addTearDown(restored.dispose);

    expect(await restored.restore(riderId: 'rider-a'), isTrue);
    expect(restored.activeDeliveryRequests, hasLength(2));
    expect(restored.activeDeliveryRecords, hasLength(2));
    expect(
      restored.activeDeliveryRequests.map((item) => item.id),
      containsAll(['batch-a', 'batch-b']),
    );
  });
}

DeliveryRequest _activeRequest() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'ORD-1',
  productName: 'Produce',
  sellerName: 'Seller',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Pickup'),
  deliveryLocation: const DeliveryLocation(address: 'Delivery'),
  pickupDeadline: DateTime(2030),
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);

RiderProfile _verifiedProfile() => const RiderProfile(
  id: 'rider-profile',
  logisticCompanyId: null,
  licenseNumber: 'LICENSE-1',
  fullName: 'Rider',
  firstName: 'Rider',
  lastName: '',
  vehicleType: RiderVehicleType.motorcycle,
  vehiclePlateNumber: 'ABC123',
  availabilityStatus: RiderAvailability.offline,
  rating: 0,
  contactNumber: '09123456789',
  email: 'rider@example.com',
  gpsLatitude: 8.48,
  gpsLongitude: 124.65,
  totalDeliveries: 0,
  employmentStatus: RiderEmploymentStatus.active,
  profilePhotoUrl: null,
);
