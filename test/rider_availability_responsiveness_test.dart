import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_availability_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_availability_card.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_request_query.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'support/rider_availability_fakes.dart';
import 'support/rider_test_models.dart';

void main() {
  testWidgets('toggle finishes while nearby deliveries are still loading', (
    tester,
  ) async {
    final requests = _DelayedRequests();
    final delivery = RiderDeliveryController(repository: requests)
      ..updateProfile(verifiedRiderProfile());
    await delivery.load(riderId: 'rider-a');
    final repository = FakeRiderAvailabilityRepository();
    final connectivity = FakeRiderConnectivityService();
    final location = FakeRiderLocationController();
    final controller = RiderAvailabilityController(
      deliveryController: delivery,
      locationController: location,
      repository: repository,
      connectivityService: connectivity,
    );
    addTearDown(() {
      controller.dispose();
      delivery.dispose();
      connectivity.dispose();
      location.dispose();
    });
    await controller.initialize(riderId: 'rider-a');
    requests.delay = true;
    repository.saveGate = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: controller,
            builder: (context, child) =>
                RiderAvailabilityCard(controller: controller),
          ),
        ),
      ),
    );

    final result = controller.setOnline(true);
    await tester.pump();
    expect(find.text('Going online…'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(controller.availability, RiderAvailability.offline);

    repository.saveGate!.complete();
    await tester.pump();
    expect((await result).isSuccess, isTrue);
    expect(requests.pending.isCompleted, isFalse);
    expect(controller.isUpdating, isFalse);
    expect(controller.availability, RiderAvailability.onlineAvailable);
    expect(find.byType(LinearProgressIndicator), findsNothing);

    requests.pending.complete(const RiderRequestPage(items: []));
    await tester.pump();
  });
}

class _DelayedRequests extends InMemoryRiderDeliveryRepository {
  bool delay = false;
  final pending = Completer<RiderRequestPage>();

  @override
  Future<RiderRequestPage> fetchNearbyRequests(RiderRequestQuery query) =>
      delay ? pending.future : super.fetchNearbyRequests(query);
}
