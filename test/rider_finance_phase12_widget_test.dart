import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/screens/rider_earnings_screen.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_ratings_widgets.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_cash_collection_card.dart';

void main() {
  testWidgets('COD card shows authoritative total and Rider controls', (
    tester,
  ) async {
    final amount = TextEditingController();
    final notes = TextEditingController();
    addTearDown(amount.dispose);
    addTearDown(notes.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiderCashCollectionCard(
              requirement: const CashOnDeliveryRequirement(
                amountToCollect: 725,
                riderCashResponsibility: 'Keep cash secure.',
              ),
              amountController: amount,
              notesController: notes,
              confirmed: false,
              issue: null,
              enabled: true,
              onConfirmed: (_) {},
              onIssue: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Collect PHP 725.00'), findsOneWidget);
    expect(find.text('Keep cash secure.'), findsOneWidget);
    expect(find.text('Amount received'), findsOneWidget);
    expect(find.text('I confirm the cash was collected'), findsOneWidget);
  });

  testWidgets('COD payment issue fits on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final amount = TextEditingController();
    final notes = TextEditingController();
    addTearDown(amount.dispose);
    addTearDown(notes.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: RiderCashCollectionCard(
              requirement: const CashOnDeliveryRequirement(
                amountToCollect: 725,
              ),
              amountController: amount,
              notesController: notes,
              confirmed: true,
              issue: CashCollectionIssue.alternateApprovedMethod,
              enabled: true,
              onConfirmed: (_) {},
              onIssue: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Buyer used another approved method'), findsOneWidget);
  });

  testWidgets('earnings screen renders full summary and period filters', (
    tester,
  ) async {
    final repository = InMemoryRiderAnalyticsRepository(
      earningsByRider: {
        'rider-a': RiderEarningsData(
          summary: const RiderEarningsSummary(),
          entries: [
            RiderEarningEntry(
              id: 'earning-1',
              deliveryId: 'delivery-1',
              orderNumber: 'AGR-1',
              occurredAt: DateTime.now(),
              description: 'Fresh produce',
              amount: 100,
              type: RiderEarningType.deliveryFee,
              payoutStatus: RiderPayoutStatus.pending,
              waitingAdjustment: 10,
              returnAdjustment: 5,
              bonus: 4,
              incentive: 3,
              deduction: 2,
              penalty: 1,
            ),
          ],
        ),
      },
    );
    final controller = RiderAnalyticsController(repository: repository);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: RiderEarningsScreen(riderId: 'rider-a', controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Yesterday'), findsOneWidget);
    expect(find.text('Gross'), findsOneWidget);
    expect(find.text('Waiting fees'), findsOneWidget);
    expect(find.text('Return fees'), findsOneWidget);
    expect(find.text('Penalties'), findsOneWidget);
    expect(find.textContaining('AGR-1'), findsOneWidget);
  });

  testWidgets('performance overview uses complete respectful metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RiderRatingsOverview(
            summary: RiderRatingsSummary(
              averageRating: 4.8,
              totalRatings: 20,
              completedDeliveries: 25,
              acceptanceRate: 92,
              completionRate: 96,
              cancellationRate: 2,
              onTimePickupRate: 88,
              onTimeDeliveryRate: 90,
              averageWaitingMinutes: 7,
              failedDeliveryRate: 2,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Acceptance'), findsOneWidget);
    expect(find.text('Completion'), findsOneWidget);
    expect(find.text('Pickup on time'), findsOneWidget);
    expect(find.text('Delivery on time'), findsOneWidget);
    expect(find.text('Average wait'), findsOneWidget);
    expect(find.text('Failed delivery'), findsOneWidget);
  });
}
