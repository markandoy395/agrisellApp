part of 'home_notification_repository.dart';

extension HomeNotificationRepositorySync on HomeNotificationRepository {
  Future<void> setRead(
    String userId,
    String notificationId, {
    required bool isRead,
  }) async {
    if (!_isCloudId(notificationId)) return;
    await cache.setRead(userId, notificationId, isRead: isRead);
    final action = isRead
        ? NotificationSyncAction.read
        : NotificationSyncAction.unread;
    await cache.queue(userId, notificationId, action);
    await _trySync(userId, notificationId, action);
  }

  Future<void> markAllRead(
    String userId,
    Iterable<HomeNotification> notifications,
  ) async {
    for (final item in notifications.where((item) => !item.isRead)) {
      await setRead(userId, item.id, isRead: true);
    }
  }

  Future<void> delete(String userId, String notificationId) async {
    if (!_isCloudId(notificationId)) return;
    await cache.remove(userId, notificationId);
    await cache.queue(userId, notificationId, NotificationSyncAction.delete);
    await _trySync(userId, notificationId, NotificationSyncAction.delete);
  }

  Future<void> deleteAll(
    String userId,
    Iterable<HomeNotification> notifications,
  ) async {
    for (final item in notifications) {
      await delete(userId, item.id);
    }
  }

  Future<void> _trySync(
    String userId,
    String id,
    NotificationSyncAction action,
  ) async {
    final client = _client;
    if (client == null) return;
    try {
      await _apply(client, userId, id, action);
      await cache.complete(userId, id);
    } on Object {
      // The queued action is retried on the next successful refresh.
    }
  }

  Future<void> _flushPending(SupabaseClient client, String userId) async {
    for (final entry in (await cache.pending(userId)).entries) {
      try {
        await _apply(client, userId, entry.key, entry.value);
        await cache.complete(userId, entry.key);
      } on Object {
        return;
      }
    }
  }

  Future<void> _apply(
    SupabaseClient client,
    String userId,
    String id,
    NotificationSyncAction action,
  ) async {
    final values = switch (action) {
      NotificationSyncAction.read => {
        'read_at': DateTime.now().toUtc().toIso8601String(),
      },
      NotificationSyncAction.unread => {'read_at': null},
      NotificationSyncAction.delete => {
        'deleted_at': DateTime.now().toUtc().toIso8601String(),
      },
    };
    await client
        .from('notifications')
        .update(values)
        .eq('notification_id', id)
        .eq('recipient_auth_user_id', userId);
  }

  bool _isCloudId(String value) => int.tryParse(value) != null;
}
