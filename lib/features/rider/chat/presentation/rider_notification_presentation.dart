import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';

extension RiderNotificationPresentation on RiderNotificationType {
  NotificationCategory get category => switch (this) {
    RiderNotificationType.deliveryRequest ||
    RiderNotificationType.deliveryAccepted ||
    RiderNotificationType.pickupReminder ||
    RiderNotificationType.deliveryReminder ||
    RiderNotificationType.cancellation ||
    RiderNotificationType.urgentRequest ||
    RiderNotificationType.requestExpired ||
    RiderNotificationType.requestAcceptedByOther ||
    RiderNotificationType.reassignment ||
    RiderNotificationType.productReady ||
    RiderNotificationType.riderArrivedAtPickup ||
    RiderNotificationType.productPickedUp ||
    RiderNotificationType.riderOnTheWay ||
    RiderNotificationType.productDelivered ||
    RiderNotificationType.deliveryCompleted => NotificationCategory.deliveries,
    RiderNotificationType.message ||
    RiderNotificationType.farmerMessage ||
    RiderNotificationType.buyerMessage ||
    RiderNotificationType.supportMessage => NotificationCategory.messages,
    RiderNotificationType.payment ||
    RiderNotificationType.verification ||
    RiderNotificationType.rating ||
    RiderNotificationType.earningsAdjustment ||
    RiderNotificationType.dispute ||
    RiderNotificationType.safetyUpdate ||
    RiderNotificationType.offlineSyncResult => NotificationCategory.system,
  };

  String get label => switch (this) {
    RiderNotificationType.deliveryRequest => 'Delivery request',
    RiderNotificationType.deliveryAccepted => 'Accepted',
    RiderNotificationType.pickupReminder => 'Pickup',
    RiderNotificationType.deliveryReminder => 'Delivery',
    RiderNotificationType.message ||
    RiderNotificationType.farmerMessage ||
    RiderNotificationType.buyerMessage ||
    RiderNotificationType.supportMessage => 'Message',
    RiderNotificationType.cancellation => 'Cancelled',
    RiderNotificationType.payment => 'Payment',
    RiderNotificationType.verification => 'Verification',
    RiderNotificationType.rating => 'Rating',
    RiderNotificationType.urgentRequest => 'Important',
    RiderNotificationType.requestExpired => 'Expired',
    RiderNotificationType.requestAcceptedByOther => 'Unavailable',
    RiderNotificationType.reassignment => 'Reassigned',
    RiderNotificationType.productReady => 'Ready',
    RiderNotificationType.earningsAdjustment => 'Earnings',
    RiderNotificationType.dispute => 'Report',
    RiderNotificationType.safetyUpdate => 'Safety',
    RiderNotificationType.offlineSyncResult => 'Sync',
    RiderNotificationType.riderArrivedAtPickup => 'At pickup',
    RiderNotificationType.productPickedUp => 'Picked up',
    RiderNotificationType.riderOnTheWay => 'On the way',
    RiderNotificationType.productDelivered => 'Delivered',
    RiderNotificationType.deliveryCompleted => 'Completed',
  };
}
