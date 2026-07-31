import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

enum RiderSafetyCategory {
  unsafePickup,
  unsafeDestination,
  suspiciousProduct,
  suspiciousCustomer,
  accident,
  vehicleBreakdown,
  theft,
  harassment,
  medicalEmergency,
  roadClosure,
  severeWeather,
  other,
}

enum RiderSafetyReportStatus {
  submitted,
  underReview,
  waitingForInformation,
  resolved,
  rejected,
  escalated,
}

enum RiderSafetyResponseAction {
  contactSupport,
  shareLocationWithSupport,
  requestReassignment,
  requestCancellation,
  continueWhenSafe,
}

class RiderSafetyReport {
  const RiderSafetyReport({
    required this.id,
    required this.deliveryId,
    required this.riderId,
    required this.stage,
    required this.location,
    required this.createdAt,
    required this.category,
    required this.description,
    this.attachments = const [],
    this.requestedActions = const {},
    this.status = RiderSafetyReportStatus.submitted,
  }) : assert(id != ''),
       assert(deliveryId != ''),
       assert(riderId != ''),
       assert(description != '');

  final String id;
  final String deliveryId;
  final String riderId;
  final DeliveryStatus stage;
  final DeliveryStatusLocation location;
  final DateTime createdAt;
  final RiderSafetyCategory category;
  final String description;

  /// Opaque protected upload references only.
  final List<String> attachments;
  final Set<RiderSafetyResponseAction> requestedActions;
  final RiderSafetyReportStatus status;

  RiderSafetyReport copyWith({RiderSafetyReportStatus? status}) =>
      RiderSafetyReport(
        id: id,
        deliveryId: deliveryId,
        riderId: riderId,
        stage: stage,
        location: location,
        createdAt: createdAt,
        category: category,
        description: description,
        attachments: attachments,
        requestedActions: requestedActions,
        status: status ?? this.status,
      );
}
