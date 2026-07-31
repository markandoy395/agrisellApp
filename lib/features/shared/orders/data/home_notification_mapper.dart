import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

class HomeNotificationMapper {
  const HomeNotificationMapper();

  HomeNotification fromRow(Map<String, Object?> row) {
    final category = _category(row['category']);
    final destination = _destination(row['destination']);
    return HomeNotification(
      id: _text(row['notification_id']),
      title: _text(row['title']),
      description: _text(row['description']),
      image: '',
      imageLabel: category == NotificationCategory.orders
          ? 'Order update'
          : 'Account update',
      showChevron: destination != HomeNotificationDestination.none,
      createdAt: DateTime.tryParse(_text(row['created_at']))?.toLocal(),
      isRead: row['read_at'] != null,
      type: _type(row['notification_type']),
      category: category,
      destination: destination,
      visibleTo: const {AuthRole.buyer, AuthRole.farmer},
      recipientId: _nullableText(row['recipient_auth_user_id']),
      orderId: _nullableText(row['order_id']),
      metadata: _metadata(row['metadata']),
    );
  }

  Map<String, Object?> toCacheRow(HomeNotification value) => {
    'notification_id': value.id,
    'recipient_auth_user_id': value.recipientId,
    'title': value.title,
    'description': value.description,
    'created_at': value.createdAt?.toUtc().toIso8601String(),
    'read_at': value.isRead ? true : null,
    'notification_type': _typeName(value.type),
    'category': value.category.name,
    'destination': value.destination.name,
    'order_id': value.orderId,
    'metadata': value.metadata,
  };

  HomeNotificationType _type(Object? value) {
    final name = _text(value);
    return switch (name) {
      'new_order' => HomeNotificationType.newOrder,
      'order_accepted' => HomeNotificationType.orderConfirmed,
      'order_ready' => HomeNotificationType.productPickedUp,
      'order_shipping' => HomeNotificationType.riderOnTheWay,
      'order_delivered' => HomeNotificationType.productDelivered,
      'order_cancelled' ||
      'order_expired' => HomeNotificationType.deliveryCancelled,
      'order_expiring' => HomeNotificationType.warning,
      'payment_update' => HomeNotificationType.paymentUpdate,
      'new_message' => HomeNotificationType.newMessage,
      'delivery_request' => HomeNotificationType.deliveryRequest,
      _ => HomeNotificationType.values.firstWhere(
        (item) => _typeName(item) == name,
        orElse: () => HomeNotificationType.verificationUpdate,
      ),
    };
  }

  String _typeName(HomeNotificationType value) {
    return switch (value) {
      HomeNotificationType.newOrder => 'new_order',
      HomeNotificationType.orderConfirmed => 'order_accepted',
      HomeNotificationType.productPickedUp => 'order_ready',
      HomeNotificationType.riderOnTheWay => 'order_shipping',
      HomeNotificationType.productDelivered => 'order_delivered',
      HomeNotificationType.deliveryCancelled => 'order_cancelled',
      HomeNotificationType.warning => 'order_expiring',
      HomeNotificationType.paymentUpdate => 'payment_update',
      HomeNotificationType.newMessage => 'new_message',
      HomeNotificationType.deliveryRequest => 'delivery_request',
      _ =>
        value.name
            .replaceAllMapped(
              RegExp('([A-Z])'),
              (match) => '_${match.group(1)!.toLowerCase()}',
            )
            .toLowerCase(),
    };
  }

  NotificationCategory _category(Object? value) {
    return NotificationCategory.values.firstWhere(
      (item) => item.name == _text(value),
      orElse: () => NotificationCategory.system,
    );
  }

  HomeNotificationDestination _destination(Object? value) {
    return HomeNotificationDestination.values.firstWhere(
      (item) => item.name == _text(value),
      orElse: () => HomeNotificationDestination.none,
    );
  }

  Map<String, Object?> _metadata(Object? value) {
    if (value is! Map) return const {};
    return {
      for (final entry in value.entries)
        if (entry.key is String) entry.key as String: entry.value,
    };
  }

  String _text(Object? value) => value?.toString().trim() ?? '';

  String? _nullableText(Object? value) {
    final text = _text(value);
    return text.isEmpty ? null : text;
  }
}
