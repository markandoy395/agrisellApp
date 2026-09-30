import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_candidate.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_rider_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final offline in [true, false]) {
    testWidgets(
      'confirmation fits small screens and returns the selected action (offline: $offline)',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 568));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.4)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showFarmerRiderConfirmationDialog(
                      context,
                      rider: FarmerRiderCandidate(
                        id: 'r1',
                        name: 'Benjomark Fuentes Andoy',
                        barangay: 'Poblacion',
                        municipality: 'Lianga',
                        sameBarangay: true,
                        rating: 5,
                        completedDeliveries: 10,
                        availabilityStatus: offline ? 'offline' : 'online',
                        proposedDeliveryFee: offline ? null : 75,
                      ),
                      delivery: FarmerRiderDeliveryDetails(
                        orderId: 'ORD-1788405835360033-F4',
                        deliveryId: 'd1',
                        pickupAddress: 'Zamora farm',
                        pickupBarangay: 'Poblacion',
                        pickupMunicipality: 'Lianga',
                        destination:
                            'Zamora, Barangay Poblacion, Lianga, Surigao del Sur, Philippines',
                        goodsSummary: '1.000 kg Lettuce',
                        requestedSchedule: DateTime(2026, 9, 4),
                        routeDistanceKm: offline ? 0.2 : null,
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final notice = find.text(
          offline
              ? 'This rider is offline. The booking expires in 45 minutes unless the rider accepts.'
              : 'The rider must accept before this order is assigned.',
        );
        await tester.ensureVisible(notice);
        await tester.pumpAndSettle();
        expect(notice, findsOneWidget);
        expect(
          find.text(offline ? 'To be confirmed' : 'PHP 75.00'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(result, isFalse);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Send request'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
