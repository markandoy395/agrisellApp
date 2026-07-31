import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_acceptance.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_card.dart';
import 'support/rider_acceptance_fixture.dart';

void main() {
  testWidgets('confirmation shows summary and blocks repeated confirmation', (
    tester,
  ) async {
    final pending = Completer<DeliveryAcceptanceOutcome>();
    var commandCount = 0;
    var acceptedCount = 0;
    await tester.pumpWidget(
      _app(
        onAccept: () {
          commandCount++;
          return pending.future;
        },
        onAccepted: () => acceptedCount++,
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(find.text('Accept this delivery?'), findsOneWidget);
    expect(find.text('Fresh Tomatoes'), findsWidgets);
    expect(find.text('PHP 180.00'), findsWidgets);

    await tester.tap(find.text('Confirm acceptance'));
    await tester.tap(find.text('Confirm acceptance'));
    await tester.pump();
    expect(commandCount, 1);
    expect(find.text('Securing this delivery...'), findsOneWidget);

    pending.complete(DeliveryAcceptanceOutcome.success(_receipt()));
    await tester.pumpAndSettle();
    expect(acceptedCount, 1);
    expect(find.text('Accept this delivery?'), findsNothing);
  });

  testWidgets('unavailable response is friendly and does not report success', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        onAccept: () async => const DeliveryAcceptanceOutcome.failure(
          DeliveryAcceptanceFailure.alreadyAssigned,
          'Another Rider has already accepted this delivery.',
        ),
        onAccepted: () => fail('must not report success'),
      ),
    );

    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm acceptance'));
    await tester.pumpAndSettle();

    expect(
      find.text('Another Rider has already accepted this delivery.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsNothing);
  });
}

Widget _app({
  required Future<DeliveryAcceptanceOutcome> Function() onAccept,
  required VoidCallback onAccepted,
}) => MaterialApp(
  home: Scaffold(
    body: RiderDeliveryRequestCard(
      request: acceptanceRequest(),
      canAccept: true,
      onAccept: onAccept,
      onAccepted: (_) => onAccepted(),
    ),
  ),
);

DeliveryAcceptanceReceipt _receipt() {
  final accepted = acceptanceRequest().copyWith(
    stage: DeliveryStage.accepted,
    assignedRiderId: 'rider-a',
  );
  return DeliveryAcceptanceReceipt(
    request: accepted,
    activeDelivery: ActiveDeliveryRecord(
      id: 'active-1',
      requestId: accepted.id,
      riderId: 'rider-a',
      acceptedAt: acceptanceNow,
      estimatedEarning: accepted.deliveryFee,
    ),
    riderAvailability: RiderAvailability.deliveryReserved,
  );
}
