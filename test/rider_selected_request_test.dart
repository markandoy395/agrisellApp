import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

void main() {
  test('only a pending, unexpired farmer selection is available to rider', () {
    final now = DateTime(2026, 8, 2, 10);
    final pending = _request(
      RiderAssignmentRequestStatus.pending,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
    final declined = _request(
      RiderAssignmentRequestStatus.declined,
      expiresAt: now.add(const Duration(minutes: 5)),
    );
    final expired = _request(
      RiderAssignmentRequestStatus.pending,
      expiresAt: now.subtract(const Duration(seconds: 1)),
    );

    expect(pending.isAvailableTo('rider-1', at: now), isTrue);
    expect(declined.isAvailableTo('rider-1', at: now), isFalse);
    expect(expired.isAvailableTo('rider-1', at: now), isFalse);
  });
}

DeliveryRequest _request(
  RiderAssignmentRequestStatus status, {
  required DateTime expiresAt,
}) => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'Order #1',
  productName: 'Tomatoes',
  sellerName: 'Farmer',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(address: 'Farm'),
  deliveryLocation: const DeliveryLocation(address: 'Buyer address'),
  pickupDeadline: expiresAt,
  assignmentRequestId: 'request-1',
  assignmentRequestStatus: status,
  expiresAt: expiresAt,
);
