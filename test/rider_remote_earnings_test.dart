import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_delivery_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_earning_guide.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_bundle.dart';

Map<String, Object?> deliveryRow(String payoutStatus) => {
  'delivery_id': 75,
  'order_id': 75,
  'delivery_status': 'completed',
  'assigned_to_current_rider': true,
  'proposed_delivery_fee': 50,
  'actual_delivery_time': '2026-10-13T06:00:00Z',
  'payment': {
    'delivery_payment_id': 'payment-75',
    'delivery_id': 75,
    'delivery_fee': 50,
    'additional_fee': 15,
    'deduction_amount': 5,
    'final_earning': 60,
    'earning_status': 'calculated',
    'payout_status': payoutStatus,
  },
};

void main() {
  for (final status in ['unpaid', 'paid']) {
    test(
      'remote completion history preserves actual earnings and $status',
      () async {
        final client = SupabaseClient(
          'https://example.supabase.co',
          'test-key',
          accessToken: () async => 'test-token',
          httpClient: MockClient(
            (request) async => http.Response(
              jsonEncode(
                request.url.path.endsWith('/rpc/current_rider_deliveries')
                    ? [deliveryRow(status)]
                    : [],
              ),
              200,
              headers: {'content-type': 'application/json'},
              request: request,
            ),
          ),
        );
        addTearDown(client.dispose);
        final repository = SupabaseRiderDeliveryRepository(
          SupabaseDeliveryDataSource(client),
        );
        final records = await repository.fetchCompletedDeliveries('rider-a');
        expect(records.single.earning!.netEarning, 60);
        final analytics = RiderDeliveryAnalyticsRepository(
          completionRecords: () => records,
        );
        final earnings = await analytics.fetchEarnings(
          riderId: 'rider-a',
          dateRange: RiderDateRange(start: DateTime(2026), end: DateTime(2027)),
        );
        expect(earnings.summary.netEarnings, 60);
        expect(earnings.summary.pendingPayments, status == 'unpaid' ? 60 : 0);
        expect(earnings.summary.paidEarnings, status == 'paid' ? 60 : 0);
      },
    );
  }

  test('payment for another delivery is rejected', () {
    final row = deliveryRow('unpaid');
    row['payment'] = {...row['payment'] as Map, 'delivery_id': 76};
    expect(() => DeliveryBundle.fromJson(row), throwsFormatException);
  });

  test(
    'missing payment remains missing rather than fabricating a paid balance',
    () {
      final row = deliveryRow('unpaid')..remove('payment');
      expect(DeliveryBundle.fromJson(row).payment, isNull);
    },
  );

  testWidgets('earning guide explains COD and opens earnings', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RiderEarningGuide(onOpenEarnings: () => opened = true),
          ),
        ),
      ),
    );
    await tester.tap(find.text('View earnings'));
    expect(opened, isTrue);
    await tester.tap(find.text('Fees, completion and payout'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Cash collected for the products belongs'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
