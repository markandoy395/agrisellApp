import 'package:flutter_test/flutter_test.dart'; 
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart'; import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart'; import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart'; import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart'; import 'package:agresell_app/features/rider/deliveries/domain/delivery_transition_validator.dart';
 void main() {
  test( 'server records every core status in order with event metadata',
    () async { final repository = InMemoryRiderDeliveryRepository(requests: [_active()]);
      var current = DeliveryStatus.accepted; DeliveryStatusSnapshot? snapshot;
      for (final next in DeliveryTransitionValidator.normalFlow
              .skip(3) .takeWhile(
                (status) => status != DeliveryStatus.productDelivered, )) {
        snapshot = await repository.updateDeliveryStatus( _command(previous: current, next: next, key: next.name),
        ); current = next;
      } final completion = await repository.completeDelivery(_completion());
      snapshot = DeliveryStatusSnapshot( request: completion.record.request,
        currentStatus: DeliveryStatus.deliveryCompleted, events: completion.record.events,
      ); expect(snapshot.currentStatus, DeliveryStatus.deliveryCompleted);
      expect(snapshot.events, hasLength(11)); final arrival = snapshot.events.firstWhere(
        (event) => event.newStatus == DeliveryStatus.arrivedAtPickup, );
      expect(arrival.eventId, isNotEmpty); expect(arrival.deliveryId, 'delivery-1');
      expect(arrival.riderId, 'rider-a'); expect(arrival.latitude, 8.48);
      expect(arrival.longitude, 124.65); expect(arrival.accuracyMeters, 5);
      expect(arrival.source.name, 'online'); expect(arrival.syncStatus.name, 'synchronized');
    }, );
 test(
    'server rejects skipped, stale, and locationless arrival updates', () async {
      final repository = InMemoryRiderDeliveryRepository(requests: [_active()]); await expectLater(
        repository.updateDeliveryStatus( _command(
            previous: DeliveryStatus.accepted, next: DeliveryStatus.productPickedUp,
            key: 'skip', ),
        ), throwsA(isA<DeliveryDomainException>()),
      ); await repository.updateDeliveryStatus(
        _command( previous: DeliveryStatus.accepted,
          next: DeliveryStatus.goingToPickup, key: 'going',
        ), );
      await expectLater( repository.updateDeliveryStatus(
          _command( previous: DeliveryStatus.goingToPickup,
            next: DeliveryStatus.arrivedAtPickup, key: 'no-location',
            location: null, ),
        ), throwsA(isA<DeliveryDomainException>()),
      ); await expectLater(
        repository.updateDeliveryStatus( _command(
            previous: DeliveryStatus.accepted, next: DeliveryStatus.goingToPickup,
            key: 'stale', ),
        ), throwsA(
          isA<DeliveryDomainException>().having( (error) => error.code,
            'code', DeliveryErrorCode.synchronizationConflict,
          ), ),
      ); },
  ); 
  test( 'duplicate idempotency key records one event and completion is immutable',
    () async { final repository = InMemoryRiderDeliveryRepository(requests: [_active()]);
      final command = _command( previous: DeliveryStatus.accepted,
        next: DeliveryStatus.goingToPickup, key: 'same-action',
      ); final first = await repository.updateDeliveryStatus(command);
      final replay = await repository.updateDeliveryStatus(command); expect(first.events, hasLength(1));
      expect(replay.events, hasLength(1)); var current = DeliveryStatus.goingToPickup;
      for (final next in DeliveryTransitionValidator.normalFlow
              .skip(4) .takeWhile(
                (status) => status != DeliveryStatus.productDelivered, )) {
        await repository.updateDeliveryStatus( _command(previous: current, next: next, key: next.name),
        ); current = next;
      } await repository.completeDelivery(_completion());
      await expectLater( repository.updateDeliveryStatus(
          _command( previous: DeliveryStatus.deliveryCompleted,
            next: DeliveryStatus.accepted, key: 'edit-completed',
          ), ),
        throwsA(isA<DeliveryDomainException>()), );
    }, );
} 
DeliveryStatusUpdateCommand _command({ required DeliveryStatus previous,
  required DeliveryStatus next, required String key,
  Object? location = _defaultLocation, }) => DeliveryStatusUpdateCommand(
  deliveryId: 'delivery-1', riderId: 'rider-a',
  previousStatus: previous, newStatus: next,
  idempotencyKey: key, location: identical(location, _defaultLocation)
      ? DeliveryStatusLocation( latitude: 8.48,
          longitude: 124.65, accuracyMeters: 5,
          timestamp: DateTime.now(), )
      : location as DeliveryStatusLocation?, note: 'Status recorded by rider.',
); 
DeliveryRequest _active() => DeliveryRequest( id: 'delivery-1',
  orderNumber: 'ORD-1', productName: 'Vegetables',
  sellerName: 'Farmer', buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation( address: 'Farm',
    latitude: 8.48, longitude: 124.65,
  ), deliveryLocation: const DeliveryLocation(
    address: 'Market', latitude: 8.48,
    longitude: 124.65, ),
  pickupDeadline: DateTime(2030), stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a', );
 const _defaultLocation = Object();
 DeliveryCompletionCommand _completion() => DeliveryCompletionCommand(
  deliveryId: 'delivery-1', riderId: 'rider-a',
  idempotencyKey: 'complete-delivery', finalLocation: _command(
    previous: DeliveryStatus.goingToPickup, next: DeliveryStatus.arrivedAtPickup,
    key: 'location', ).location!,
  recipientName: 'Buyer', proofReferences: const {
    DeliveryConfirmationMethod.buyerConfirmation: 'protected://delivery/delivery-1/buyer',
    DeliveryConfirmationMethod.recipientName: 'protected://delivery/delivery-1/recipient',
    DeliveryConfirmationMethod.gpsLocation: 'protected://delivery/delivery-1/gps',
    DeliveryConfirmationMethod.timestamp: 'protected://delivery/delivery-1/time',
  }, );
