import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_cash_out_dialog.dart';
import 'package:agresell_app/features/farmer/reservations/presentation/widgets/farmer_delivery_fee_dialog.dart';

const method = RiderWithdrawalMethod(
  methodId: 'owned-method',
  payoutMethod: 'gcash',
  accountName: 'Rider',
  accountNumber: '09123456789',
);

class RetryRepository extends InMemoryRiderAnalyticsRepository {
  RetryRepository()
    : super(
        withdrawalMethodsByRider: {
          'rider': [method],
        },
      );
  final submissions = <RiderWithdrawalRequest>[];
  @override
  Future<RiderWithdrawalRequest> submitWithdrawalRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  }) async {
    submissions.add(request);
    throw StateError('Response lost');
  }
}

void main() {
  test(
    'remote wallet and cash out use server balance, saved method and retry key',
    () async {
      final calls = <http.Request>[];
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        accessToken: () async => 'test-token',
        httpClient: MockClient((request) async {
          calls.add(request);
          final name = request.url.pathSegments.last;
          final value = switch (name) {
            'current_rider_wallet' => {
              'available': 40.25,
              'reserved': 10,
              'paid': 70,
            },
            'submit_rider_payout_request' => {
              'requestId': 'recorded',
              'amount': 40.25,
              'status': 'pending',
            },
            _ => [],
          };
          return http.Response(
            jsonEncode(value),
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final repository = SupabaseRiderAnalyticsRepository(client: client);
      expect((await repository.fetchWallet()).available, 40.25);
      final controller = RiderAnalyticsController(repository: repository);
      addTearDown(controller.dispose);
      await controller.loadWallet(riderId: 'untrusted-client-id');
      expect(controller.wallet!.available, 40.25);
      await repository.submitWithdrawalRequest(
        riderId: 'untrusted-client-id',
        request: const RiderWithdrawalRequest(
          requestId: 'stable-key',
          withdrawalMethodId: 'owned-method',
          amount: 40.25,
          payoutMethod: 'gcash',
          accountName: 'ignored',
          accountNumber: 'ignored',
        ),
      );
      expect(jsonDecode(calls.last.body), {
        'p_method_id': 'owned-method',
        'p_amount': 40.25,
        'p_request_key': 'stable-key',
        'p_notes': null,
      });
    },
  );

  test(
    'wallet failure clears balance and disables cached withdrawals',
    () async {
      var fail = false;
      final client = SupabaseClient(
        'https://example.supabase.co',
        'test-key',
        accessToken: () async => 'test-token',
        httpClient: MockClient((request) async {
          if (fail)
            return http.Response(
              '{"message":"Unavailable"}',
              503,
              request: request,
            );
          return http.Response(
            request.url.path.endsWith('current_rider_wallet')
                ? '{"available":12,"reserved":0,"paid":0}'
                : '[]',
            200,
            headers: {'content-type': 'application/json'},
            request: request,
          );
        }),
      );
      addTearDown(client.dispose);
      final controller = RiderAnalyticsController(
        repository: SupabaseRiderAnalyticsRepository(client: client),
      );
      addTearDown(controller.dispose);
      await controller.loadWallet(riderId: 'rider');
      expect(controller.wallet!.available, 12);
      fail = true;
      await controller.loadWallet(riderId: 'rider');
      expect(controller.wallet, isNull);
      expect(controller.walletError, isNotNull);
      expect(controller.withdrawalRequests, isEmpty);
    },
  );

  testWidgets(
    'cash out retains cents and the request key after a lost response',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = RetryRepository();
      final controller = RiderAnalyticsController(repository: repository);
      addTearDown(controller.dispose);
      await controller.loadWithdrawalMethods(riderId: 'rider');
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: RiderCashOutDialog(
              riderId: 'rider',
              controller: controller,
              availableEarnings: 50.25,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextFormField).first, '50.25');
      for (var i = 0; i < 2; i++) {
        await tester.ensureVisible(find.text('Submit Cash Out'));
        await tester.tap(find.text('Submit Cash Out'));
        await tester.pumpAndSettle();
      }
      expect(repository.submissions.length, 2);
      expect(repository.submissions.first.amount, 50.25);
      expect(repository.submissions.first.withdrawalMethodId, 'owned-method');
      expect(
        repository.submissions.last.requestId,
        repository.submissions.first.requestId,
      );
    },
  );

  testWidgets('farmer must enter a positive fee before reviewing', (
    tester,
  ) async {
    double? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showFarmerDeliveryFeeDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review request'));
    await tester.pumpAndSettle();
    expect(
      find.text('Enter a positive fee with up to two decimals.'),
      findsOneWidget,
    );
    await tester.enterText(find.byType(TextFormField), '45.50');
    await tester.tap(find.text('Review request'));
    await tester.pumpAndSettle();
    expect(result, 45.50);
  });
}
