import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_request_panel.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

void main() {
  testWidgets('farmer sees the live remaining booking time', (tester) async {
    var now = DateTime(2026, 8, 11, 10);
    final request = _request(
      status: RiderAssignmentRequestStatus.pending,
      expiresAt: now.add(const Duration(minutes: 42)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerRiderRequestPanel(request: request, now: () => now),
        ),
      ),
    );

    expect(find.text('Expires in 42 minutes'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('rider-booking-remaining-time')),
      findsOneWidget,
    );

    now = now.add(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 30));
    expect(find.text('Expires in 41 minutes'), findsOneWidget);
  });

  testWidgets('accepted assignment no longer shows an expiration countdown', (
    tester,
  ) async {
    final request = _request(
      status: RiderAssignmentRequestStatus.accepted,
      expiresAt: DateTime.now().add(const Duration(minutes: 40)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FarmerRiderRequestPanel(request: request)),
      ),
    );

    expect(find.text('Accepted'), findsOneWidget);
    expect(find.textContaining('Expires in'), findsNothing);
    expect(
      find.byKey(const ValueKey('rider-booking-remaining-time')),
      findsNothing,
    );
  });

  testWidgets('expired booking allows the farmer to choose another Rider', (
    tester,
  ) async {
    var choseAnother = false;
    final request = _request(
      status: RiderAssignmentRequestStatus.pending,
      expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerRiderRequestPanel(
            request: request,
            onChooseAnother: () => choseAnother = true,
          ),
        ),
      ),
    );

    expect(find.text('Expired'), findsOneWidget);
    await tester.tap(find.text('Choose another rider'));
    expect(choseAnother, isTrue);
  });
}

FarmerRiderRequest _request({
  required RiderAssignmentRequestStatus status,
  required DateTime expiresAt,
}) => FarmerRiderRequest(
  id: 'request-1',
  deliveryId: 'delivery-1',
  orderId: 'ORDER-F1',
  riderId: 'rider-1',
  riderName: 'Offline Manual',
  status: status,
  requestedSchedule: DateTime.now().add(const Duration(hours: 2)),
  requestedAt: DateTime.now(),
  expiresAt: expiresAt,
  respondedAt: status.isPending ? null : DateTime.now(),
);
