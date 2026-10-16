import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_errors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

void main() {
  Future<void> run({
    String status = 'arrived_at_pickup',
    bool assigned = true,
    String? errorCode,
    DeliveryErrorCode? expectedFailure,
  }) async {
    final calls = <String>[];
    final client = SupabaseClient(
      'https://example.supabase.co',
      'test-key',
      accessToken: () async => 'test-token',
      httpClient: MockClient((request) async {
        calls.add(request.url.path);
        return http.Response(
          jsonEncode(
            errorCode != null
                ? {
                    'code': errorCode,
                    'message': 'Session or service unavailable',
                  }
                : [
                    {
                      'delivery_id': 7,
                      'order_id': 9,
                      'delivery_status': status,
                      'assigned_to_current_rider': assigned,
                      'product_image_url': 'https://example.test/product.jpg',
                      'created_at': '2026-10-15T01:00:00Z',
                    },
                  ],
          ),
          errorCode == null ? 200 : 400,
          headers: {'content-type': 'application/json'},
          request: request,
        );
      }),
    );
    addTearDown(client.dispose);
    final repository = SupabaseRiderDeliveryRepository(
      SupabaseDeliveryDataSource(client),
    );
    final operation = repository.updateDeliveryStatus(
      const DeliveryStatusUpdateCommand(
        deliveryId: '7',
        riderId: 'rider-a',
        previousStatus: DeliveryStatus.waitingForProduct,
        newStatus: DeliveryStatus.pickupConfirmationRequired,
        idempotencyKey: 'key-7',
      ),
    );
    if (expectedFailure != null) {
      await expectLater(
        operation,
        throwsA(
          isA<DeliveryDomainException>().having(
            (error) => error.code,
            'code',
            expectedFailure,
          ),
        ),
      );
    } else {
      final snapshot = await operation;
      expect(snapshot.currentStatus, DeliveryStatus.pickupConfirmationRequired);
      expect(
        snapshot.request.productImageUrl,
        'https://example.test/product.jpg',
      );
      expect(
        snapshot.events.last.newStatus,
        DeliveryStatus.pickupConfirmationRequired,
      );
    }
    expect(calls, ['/rest/v1/rpc/current_rider_deliveries']);
  }

  test(
    'pickup confirmation substep succeeds after authorized server refresh',
    () => run(),
  );
  test(
    'pickup confirmation cannot mark an unassigned delivery',
    () => run(
      assigned: false,
      expectedFailure: DeliveryErrorCode.unauthorizedOperation,
    ),
  );
  test(
    'pickup confirmation rejects stale server state',
    () => run(
      status: 'picked_up',
      expectedFailure: DeliveryErrorCode.synchronizationConflict,
    ),
  );
  test(
    'refresh authorization errors retain their domain error instead of generic failure',
    () => run(
      errorCode: '42501',
      expectedFailure: DeliveryErrorCode.unauthorizedOperation,
    ),
  );
  test(
    'refresh database errors are handled for the confirmation substep',
    () => run(
      errorCode: 'PGRST202',
      expectedFailure: DeliveryErrorCode.invalidStatusTransition,
    ),
  );
}
