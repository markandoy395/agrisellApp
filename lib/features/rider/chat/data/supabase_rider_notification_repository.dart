import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/chat/data/rider_notification_repository.dart';
import 'package:agresell_app/features/rider/chat/domain/rider_notification.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

class SupabaseRiderNotificationRepository
    implements RiderNotificationRepository, RiderNotificationUnreadRepository {
  SupabaseRiderNotificationRepository({
    HomeNotificationRepository? repository,
    SupabaseClient? client,
  }) : _client = client ?? AgrisellSupabase.client,
       _repository = repository ?? HomeNotificationRepository(client: client);

  final SupabaseClient _client;
  final HomeNotificationRepository _repository;

  @override
  Stream<List<RiderNotification>> watchNotifications({
    required String riderId,
  }) {
    final authId = _authId;
    if (authId == null) {
      return Stream.error(
        const RiderNotificationRepositoryException(
          'Authentication is required to load notifications.',
        ),
      );
    }
    return _repository
        .watchForUser(authId)
        .map(
          (values) => values
              .map((item) => _toRiderNotification(item, riderId))
              .toList(growable: false),
        );
  }

  @override
  Future<void> markRead({
    required String riderId,
    required String notificationId,
  }) => _setRead(notificationId, isRead: true);

  @override
  Future<void> markUnread({
    required String riderId,
    required String notificationId,
  }) => _setRead(notificationId, isRead: false);

  @override
  Future<void> markAllRead({required String riderId}) async {
    final authId = _requireAuthId();
    final values = await _repository.loadCachedForUser(authId);
    await _repository.markAllRead(authId, values);
  }

  @override
  Future<bool> delete({
    required String riderId,
    required String notificationId,
  }) async {
    if (int.tryParse(notificationId) == null) return false;
    await _repository.delete(_requireAuthId(), notificationId);
    return true;
  }

  Future<void> _setRead(String notificationId, {required bool isRead}) {
    return _repository.setRead(
      _requireAuthId(),
      notificationId,
      isRead: isRead,
    );
  }

  RiderNotification _toRiderNotification(
    HomeNotification value,
    String riderId,
  ) {
    return RiderNotification(
      id: value.id,
      eventId: _metadataText(value, 'event_id') ?? value.id,
      riderId: riderId,
      type: _type(value),
      title: value.title,
      message: value.description,
      createdAt: value.createdAt ?? DateTime.now(),
      deliveryId: _metadataText(value, 'delivery_id'),
      conversationId: _metadataText(value, 'conversation_id'),
      earningsId: _metadataText(value, 'earnings_id'),
      reportId: _metadataText(value, 'report_id'),
      isRead: value.isRead,
      canDelete: true,
    );
  }

  RiderNotificationType _type(HomeNotification value) {
    final requestStatus = _metadataText(value, 'request_status');
    if (requestStatus == 'expired') {
      return RiderNotificationType.requestExpired;
    }
    if (requestStatus == 'cancelled' || requestStatus == 'failed') {
      return RiderNotificationType.cancellation;
    }
    return switch (value.type) {
      HomeNotificationType.deliveryRequest =>
        RiderNotificationType.deliveryRequest,
      HomeNotificationType.newMessage => RiderNotificationType.message,
      HomeNotificationType.paymentUpdate => RiderNotificationType.payment,
      HomeNotificationType.riderAccepted =>
        RiderNotificationType.deliveryAccepted,
      HomeNotificationType.productPickedUp =>
        RiderNotificationType.productPickedUp,
      HomeNotificationType.riderOnTheWay => RiderNotificationType.riderOnTheWay,
      HomeNotificationType.productDelivered =>
        RiderNotificationType.productDelivered,
      HomeNotificationType.deliveryCompleted =>
        RiderNotificationType.deliveryCompleted,
      HomeNotificationType.deliveryCancelled =>
        RiderNotificationType.cancellation,
      HomeNotificationType.warning => RiderNotificationType.urgentRequest,
      _ => RiderNotificationType.verification,
    };
  }

  String? _metadataText(HomeNotification value, String key) {
    final text = value.metadata[key]?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  String? get _authId => _client.auth.currentUser?.id;

  String _requireAuthId() {
    final value = _authId;
    if (value == null) {
      throw const RiderNotificationRepositoryException(
        'Authentication is required to update notifications.',
      );
    }
    return value;
  }
}
