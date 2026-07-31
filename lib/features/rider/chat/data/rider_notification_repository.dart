import 'dart:async';

import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';

/// Contract for a rider's private push and in-app notification feed.
abstract interface class RiderNotificationRepository {
  Stream<List<RiderNotification>> watchNotifications({required String riderId});

  Future<void> markRead({
    required String riderId,
    required String notificationId,
  });

  Future<void> markAllRead({required String riderId});

  Future<bool> delete({
    required String riderId,
    required String notificationId,
  });
}

abstract interface class RiderNotificationUnreadRepository {
  Future<void> markUnread({
    required String riderId,
    required String notificationId,
  });
}

/// Empty local adapter for development and tests; it never creates sample data.
class InMemoryRiderNotificationRepository
    implements RiderNotificationRepository, RiderNotificationUnreadRepository {
  InMemoryRiderNotificationRepository({
    Iterable<RiderNotification> notifications = const [],
  }) : _notifications = {
         for (final notification in notifications)
           notification.eventId: notification,
       };

  final Map<String, RiderNotification> _notifications;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  @override
  Stream<List<RiderNotification>> watchNotifications({
    required String riderId,
  }) {
    return Stream.multi((controller) {
      void emit() => controller.add(_currentNotifications(riderId));
      emit();
      final subscription = _changes.stream.listen((_) => emit());
      controller.onCancel = subscription.cancel;
    });
  }

  @override
  Future<void> markRead({
    required String riderId,
    required String notificationId,
  }) async {
    final notification = _notificationFor(riderId, notificationId);
    if (notification == null || notification.isRead) return;
    _notifications[notification.eventId] = notification.copyWith(isRead: true);
    _changes.add(null);
  }

  @override
  Future<void> markAllRead({required String riderId}) async {
    var changed = false;
    for (final entry in _notifications.entries.toList()) {
      if (_isVisibleTo(entry.value, riderId) && !entry.value.isRead) {
        _notifications[entry.key] = entry.value.copyWith(isRead: true);
        changed = true;
      }
    }
    if (changed) _changes.add(null);
  }

  @override
  Future<void> markUnread({
    required String riderId,
    required String notificationId,
  }) async {
    final notification = _notificationFor(riderId, notificationId);
    if (notification == null || !notification.isRead) return;
    _notifications[notification.eventId] = notification.copyWith(isRead: false);
    _changes.add(null);
  }

  @override
  Future<bool> delete({
    required String riderId,
    required String notificationId,
  }) async {
    final notification = _notificationFor(riderId, notificationId);
    if (notification == null || !notification.canDelete) return false;
    _notifications.remove(notification.eventId);
    _changes.add(null);
    return true;
  }

  RiderNotification? _notificationFor(String riderId, String id) {
    for (final notification in _notifications.values) {
      if (notification.id == id && _isVisibleTo(notification, riderId)) {
        return notification;
      }
    }
    return null;
  }

  bool _isVisibleTo(RiderNotification notification, String riderId) =>
      notification.riderId == null || notification.riderId == riderId;

  List<RiderNotification> _currentNotifications(String riderId) {
    final notifications =
        _notifications.values
            .where((notification) => _isVisibleTo(notification, riderId))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<RiderNotification>.unmodifiable(notifications);
  }
}

class RiderNotificationRepositoryException implements Exception {
  const RiderNotificationRepositoryException(
    this.message, {
    this.isOffline = false,
  });

  final String message;
  final bool isOffline;

  @override
  String toString() => message;
}
