import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/chat/data/rider_notification_repository.dart';
import 'package:agresell_app/features/rider/chat/data/supabase_rider_notification_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_communication_state.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';

class RiderNotificationsController extends ChangeNotifier {
  RiderNotificationsController({RiderNotificationRepository? repository})
    : _repository = repository ?? _defaultRepository();

  static RiderNotificationRepository _defaultRepository() {
    if (AgrisellSupabase.isInitialized &&
        AgrisellSupabase.client.auth.currentUser != null) {
      return SupabaseRiderNotificationRepository();
    }
    return InMemoryRiderNotificationRepository();
  }

  final RiderNotificationRepository _repository;
  RiderCommunicationLoadState _state = RiderCommunicationLoadState.ready;
  StreamSubscription<List<RiderNotification>>? _subscription;
  List<RiderNotification> _notifications = const [];
  String? _riderId;
  String? _errorMessage;
  String? _actionError;

  RiderCommunicationLoadState get state => _state;
  List<RiderNotification> get notifications =>
      List.unmodifiable(_notifications);
  int get unreadCount => _notifications.where((item) => !item.isRead).length;
  String? get errorMessage => _errorMessage;
  String? get actionError => _actionError;

  Future<void> load({required String riderId}) async {
    await _subscription?.cancel();
    _riderId = riderId;
    _state = RiderCommunicationLoadState.loading;
    _errorMessage = null;
    notifyListeners();
    _subscription = _repository
        .watchNotifications(riderId: riderId)
        .listen(_onNotifications, onError: _onNotificationError);
  }

  Future<bool> markRead(String notificationId) async {
    final riderId = _riderId;
    if (riderId == null) return false;
    try {
      await _repository.markRead(
        riderId: riderId,
        notificationId: notificationId,
      );
      _notifications = [
        for (final notification in _notifications)
          notification.id == notificationId
              ? notification.copyWith(isRead: true)
              : notification,
      ];
      _actionError = null;
      notifyListeners();
      return true;
    } on RiderNotificationRepositoryException catch (error) {
      _actionError = error.message;
    } catch (_) {
      _actionError = 'Notification could not be updated.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> markAllRead() async {
    final riderId = _riderId;
    if (riderId == null) return false;
    try {
      await _repository.markAllRead(riderId: riderId);
      _notifications = [
        for (final notification in _notifications)
          notification.copyWith(isRead: true),
      ];
      _actionError = null;
      notifyListeners();
      return true;
    } on RiderNotificationRepositoryException catch (error) {
      _actionError = error.message;
    } catch (_) {
      _actionError = 'Notifications could not be updated.';
    }
    notifyListeners();
    return false;
  }

  Future<bool> markUnread(String notificationId) async {
    final riderId = _riderId;
    if (riderId == null) return false;
    try {
      if (_repository case final RiderNotificationUnreadRepository repository) {
        await repository.markUnread(
          riderId: riderId,
          notificationId: notificationId,
        );
      }
      _notifications = [
        for (final notification in _notifications)
          notification.id == notificationId
              ? notification.copyWith(isRead: false)
              : notification,
      ];
      _actionError = null;
      notifyListeners();
      return true;
    } catch (_) {
      _actionError = 'Notification could not be updated.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearAll() async {
    final riderId = _riderId;
    if (riderId == null) return false;
    final deletable = _notifications.where((item) => item.canDelete).toList();
    try {
      for (final notification in deletable) {
        await _repository.delete(
          riderId: riderId,
          notificationId: notification.id,
        );
      }
      final ids = deletable.map((item) => item.id).toSet();
      _notifications = _notifications
          .where((item) => !ids.contains(item.id))
          .toList();
      _actionError = null;
      notifyListeners();
      return true;
    } catch (_) {
      _actionError = 'Notifications could not be cleared.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String notificationId) async {
    final riderId = _riderId;
    if (riderId == null) return false;
    try {
      final deleted = await _repository.delete(
        riderId: riderId,
        notificationId: notificationId,
      );
      if (!deleted) {
        _actionError = 'This notification cannot be deleted.';
        notifyListeners();
        return false;
      }
      _notifications = _notifications
          .where((notification) => notification.id != notificationId)
          .toList(growable: false);
      _actionError = null;
      notifyListeners();
      return true;
    } on RiderNotificationRepositoryException catch (error) {
      _actionError = error.message;
    } catch (_) {
      _actionError = 'Notification could not be deleted.';
    }
    notifyListeners();
    return false;
  }

  void _onNotifications(List<RiderNotification> notifications) {
    _notifications = List.unmodifiable(notifications);
    _state = RiderCommunicationLoadState.ready;
    _errorMessage = null;
    notifyListeners();
  }

  void _onNotificationError(Object error, StackTrace stackTrace) {
    _state = error is RiderNotificationRepositoryException && error.isOffline
        ? RiderCommunicationLoadState.offline
        : RiderCommunicationLoadState.error;
    _errorMessage = error is RiderNotificationRepositoryException
        ? error.message
        : 'Notifications could not be loaded.';
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
