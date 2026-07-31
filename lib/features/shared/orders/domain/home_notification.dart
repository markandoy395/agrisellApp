import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';

enum HomeNotificationType {
  newOrder,
  orderConfirmed,
  paymentUpdate,
  productApproved,
  productRejected,
  productSold,
  productOutOfStock,
  newMessage,
  deliveryRequest,
  riderAccepted,
  riderArrived,
  productPickedUp,
  riderOnTheWay,
  productDelivered,
  deliveryCompleted,
  deliveryCancelled,
  verificationUpdate,
  announcement,
  warning,
}

enum HomeNotificationDestination {
  orders,
  deliveries,
  messages,
  products,
  account,
  none,
}

class HomeNotification {
  const HomeNotification({
    this.id = '',
    required this.title,
    required this.description,
    required this.image,
    required this.imageLabel,
    this.showChevron = false,
    this.createdAt,
    this.isRead = false,
    this.type = HomeNotificationType.orderConfirmed,
    this.category = NotificationCategory.orders,
    this.destination = HomeNotificationDestination.orders,
    this.visibleTo = const {AuthRole.buyer, AuthRole.farmer},
    this.recipientId,
    this.orderId,
    this.metadata = const {},
  });

  final String id;
  final String title;
  final String description;
  final String image;
  final String imageLabel;
  final bool showChevron;
  final DateTime? createdAt;
  final bool isRead;
  final HomeNotificationType type;
  final NotificationCategory category;
  final HomeNotificationDestination destination;
  final Set<AuthRole> visibleTo;
  final String? recipientId;
  final String? orderId;
  final Map<String, Object?> metadata;

  bool isVisibleTo(AuthRole role, {String? userId}) {
    final matchesRecipient = recipientId == null || recipientId == userId;
    return visibleTo.contains(role) && matchesRecipient;
  }

  HomeNotification copyWith({String? id, DateTime? createdAt, bool? isRead}) {
    return HomeNotification(
      id: id ?? this.id,
      title: title,
      description: description,
      image: image,
      imageLabel: imageLabel,
      showChevron: showChevron,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type,
      category: category,
      destination: destination,
      visibleTo: visibleTo,
      recipientId: recipientId,
      orderId: orderId,
      metadata: metadata,
    );
  }
}
