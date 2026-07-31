enum RiderNotificationType {
  deliveryRequest,
  deliveryAccepted,
  pickupReminder,
  deliveryReminder,
  message,
  cancellation,
  payment,
  verification,
  rating,
  urgentRequest,
  requestExpired,
  requestAcceptedByOther,
  farmerMessage,
  buyerMessage,
  supportMessage,
  reassignment,
  productReady,
  earningsAdjustment,
  dispute,
  safetyUpdate,
  offlineSyncResult,
  riderArrivedAtPickup,
  productPickedUp,
  riderOnTheWay,
  productDelivered,
  deliveryCompleted,
}

enum RiderNotificationDestination {
  delivery,
  conversation,
  earnings,
  report,
  none,
}

class RiderNotification {
  const RiderNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.riderId,
    String? eventId,
    this.deliveryId,
    this.conversationId,
    this.earningsId,
    this.reportId,
    this.isRead = false,
    this.canDelete = false,
  }) : assert(id != ''),
       assert(title != ''),
       assert(message != ''),
       eventId = eventId ?? id;

  final String id;

  /// Stable source event identifier used to deduplicate push/in-app delivery.
  final String eventId;
  final String? riderId;
  final RiderNotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final String? deliveryId;
  final String? conversationId;
  final String? earningsId;
  final String? reportId;
  final bool isRead;
  final bool canDelete;

  RiderNotificationDestination get destination {
    if (conversationId != null) {
      return RiderNotificationDestination.conversation;
    }
    if (earningsId != null) return RiderNotificationDestination.earnings;
    if (reportId != null) return RiderNotificationDestination.report;
    if (deliveryId != null) return RiderNotificationDestination.delivery;
    return RiderNotificationDestination.none;
  }

  RiderNotification copyWith({bool? isRead}) => RiderNotification(
    id: id,
    eventId: eventId,
    riderId: riderId,
    type: type,
    title: title,
    message: message,
    createdAt: createdAt,
    deliveryId: deliveryId,
    conversationId: conversationId,
    earningsId: earningsId,
    reportId: reportId,
    isRead: isRead ?? this.isRead,
    canDelete: canDelete,
  );
}

class RiderNotificationAction {
  const RiderNotificationAction({
    required this.notificationId,
    required this.destination,
    this.deliveryId,
    this.conversationId,
    this.earningsId,
    this.reportId,
  });

  factory RiderNotificationAction.fromNotification(RiderNotification value) =>
      RiderNotificationAction(
        notificationId: value.id,
        destination: value.destination,
        deliveryId: value.deliveryId,
        conversationId: value.conversationId,
        earningsId: value.earningsId,
        reportId: value.reportId,
      );

  final String notificationId;
  final RiderNotificationDestination destination;
  final String? deliveryId;
  final String? conversationId;
  final String? earningsId;
  final String? reportId;
}
