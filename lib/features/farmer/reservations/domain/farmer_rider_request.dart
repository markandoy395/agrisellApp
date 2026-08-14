import 'package:agresell_app/features/shared/orders/domain/rider_assignment_request_status.dart';

class FarmerRiderRequest {
  const FarmerRiderRequest({
    required this.id,
    required this.deliveryId,
    required this.orderId,
    required this.riderId,
    required this.riderName,
    required this.status,
    required this.requestedSchedule,
    required this.requestedAt,
    required this.expiresAt,
    this.riderBarangay = '',
    this.riderMunicipality = '',
    this.riderProfilePhotoPath,
    this.proposedDeliveryFee,
    this.respondedAt,
    this.failureReason,
  });

  final String id;
  final String deliveryId;
  final String orderId;
  final String riderId;
  final String riderName;
  final String riderBarangay;
  final String riderMunicipality;
  final String? riderProfilePhotoPath;
  final RiderAssignmentRequestStatus status;
  final DateTime requestedSchedule;
  final double? proposedDeliveryFee;
  final DateTime requestedAt;
  final DateTime expiresAt;
  final DateTime? respondedAt;
  final String? failureReason;

  bool get isExpiredNow =>
      status.isPending && !DateTime.now().isBefore(expiresAt);
}
