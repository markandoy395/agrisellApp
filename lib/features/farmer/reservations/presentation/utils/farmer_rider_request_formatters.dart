import 'package:agresell_app/features/farmer/reservations/domain/farmer_rider_request.dart';
import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

abstract final class FarmerRiderRequestFormatters {
  static String message(
    FarmerRiderRequest request,
    RiderAssignmentRequestStatus status,
  ) => switch (status) {
    RiderAssignmentRequestStatus.pending =>
      '${request.riderName} has until ${formatTime(request.expiresAt)} to respond.',
    RiderAssignmentRequestStatus.accepted =>
      '${request.riderName} is assigned and can begin the delivery workflow.',
    RiderAssignmentRequestStatus.declined =>
      '${request.riderName} declined. Select another eligible rider.',
    RiderAssignmentRequestStatus.expired =>
      '${request.riderName} did not respond before the request expired.',
    RiderAssignmentRequestStatus.cancelled =>
      'This request was cancelled. You may choose another rider.',
    RiderAssignmentRequestStatus.failed =>
      request.failureReason ?? 'The rider became unavailable or ineligible.',
  };

  static String formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour == 0
        ? 12
        : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${local.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String remainingLabel(DateTime expiresAt, DateTime now) {
    final remaining = expiresAt.difference(now);
    if (remaining <= Duration.zero) return 'Booking expired';
    final minutes = (remaining.inSeconds / 60).ceil();
    return 'Expires in $minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }
}
