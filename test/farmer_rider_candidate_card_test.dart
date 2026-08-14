import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_candidate_card.dart';

void main() {
  testWidgets('shows Rider pickup distance, route, and online status', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerRiderCandidateCard(
            rider: _rider(distanceKm: 1.2),
            farmerToBuyerDistanceKm: 12.4,
            isSubmitting: false,
            onSelect: () {},
          ),
        ),
      ),
    );

    expect(find.text('1.2 km from pickup'), findsOneWidget);
    expect(find.text('Farmer to buyer: 12.4 km'), findsOneWidget);
    expect(find.text('Online'), findsOneWidget);
  });

  testWidgets('shows offline status and its pickup distance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FarmerRiderCandidateCard(
            rider: _rider(
              distanceKm: 18.3,
              availabilityStatus: 'offline',
              isRequestable: false,
              destinationSupported: false,
            ),
            farmerToBuyerDistanceKm: 9.8,
            isSubmitting: false,
            onSelect: null,
          ),
        ),
      ),
    );

    expect(find.text('18.3 km from pickup'), findsOneWidget);
    expect(find.textContaining('Nearby'), findsNothing);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Outside 15 km service area'), findsOneWidget);
  });

  testWidgets('stays overflow-free at a tight width and larger text', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Scaffold(
            body: SizedBox(
              width: 320,
              child: FarmerRiderCandidateCard(
                rider: _rider(distanceKm: 1.2),
                farmerToBuyerDistanceKm: 124.4,
                isSubmitting: false,
                onSelect: () {},
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}

FarmerRiderCandidate _rider({
  required double distanceKm,
  String availabilityStatus = 'online',
  bool isRequestable = true,
  bool destinationSupported = true,
}) => FarmerRiderCandidate(
  id: 'rider-1',
  name: 'Ana Rider',
  barangay: 'Poblacion',
  municipality: 'Lianga',
  sameBarangay: true,
  sameMunicipality: true,
  availabilityStatus: availabilityStatus,
  isRequestable: isRequestable,
  destinationSupported: destinationSupported,
  distanceKm: distanceKm,
  locationIsFresh: true,
  rating: 4.8,
  completedDeliveries: 42,
);
