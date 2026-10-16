import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_active_trip_summary.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_overview.dart';
import 'support/rider_test_models.dart';

void main() {
  for (final routeSummary in [true, false]) {
    testWidgets(
      '${routeSummary ? 'route summary' : 'delivery information'} restores independently of scroll offset',
      (tester) async {
        final bucket = PageStorageBucket();
        final request = assignedDeliveryRequest();
        final plan = RiderBatchPlan(
          deliveries: [request],
          stops: const [],
          totalDistanceKm: 2,
          estimatedTravelMinutes: 10,
          combinedWeightKg: 5,
          vehicleCapacityKg: 30,
          handlingWarnings: const [],
        );
        Widget host({required bool showDetails}) => MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: PageStorage(
              bucket: bucket,
              child: ListView(
                key: const PageStorageKey<String>('delivery-scroll'),
                children: [
                  if (showDetails)
                    if (routeSummary)
                      RiderActiveTripSummary(deliveries: [request], plan: plan)
                    else
                      RiderDeliveryRequestOverview(request: request),
                  const SizedBox(height: 1800),
                ],
              ),
            ),
          ),
        );

        // Populate the list's storage with a real double scroll offset first.
        await tester.pumpWidget(host(showDetails: false));
        await tester.drag(find.byType(ListView), const Offset(0, -160));
        await tester.pumpAndSettle();
        final offset = tester
            .state<ScrollableState>(find.byType(Scrollable))
            .position
            .pixels;
        expect(offset, greaterThan(0));
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(host(showDetails: true));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .state<ScrollableState>(find.byType(Scrollable))
              .position
              .pixels,
          offset,
        );

        final tile = find.byType(ExpansionTile);
        await tester.ensureVisible(
          find.text(
            routeSummary
                ? 'Route and handling details'
                : 'Delivery information',
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(
          find.text(
            routeSummary
                ? 'Route and handling details'
                : 'Delivery information',
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<Expansible>(
                find.descendant(of: tile, matching: find.byType(Expansible)),
              )
              .controller
              .isExpanded,
          isTrue,
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpWidget(host(showDetails: true));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester
              .widget<Expansible>(
                find.descendant(of: tile, matching: find.byType(Expansible)),
              )
              .controller
              .isExpanded,
          isTrue,
        );
      },
    );
  }
}
