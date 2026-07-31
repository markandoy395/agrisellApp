import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/orders/data/home_notification_mapper.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

enum NotificationSyncAction { read, unread, delete }

abstract interface class HomeNotificationCache {
  Future<List<HomeNotification>> read(String userId);
  Future<void> write(String userId, List<HomeNotification> notifications);
  Future<void> setRead(String userId, String id, {required bool isRead});
  Future<void> remove(String userId, String id);
  Future<Map<String, NotificationSyncAction>> pending(String userId);
  Future<void> queue(String userId, String id, NotificationSyncAction action);
  Future<void> complete(String userId, String id);
}

class SharedPreferencesHomeNotificationCache implements HomeNotificationCache {
  const SharedPreferencesHomeNotificationCache();

  static const maxEntries = 60;
  static const _mapper = HomeNotificationMapper();

  @override
  Future<List<HomeNotification>> read(String userId) async {
    final value = (await SharedPreferences.getInstance()).getString(
      _feedKey(userId),
    );
    if (value == null) return const [];
    try {
      final decoded = jsonDecode(value);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map(
            (row) => _mapper.fromRow(
              row.map((key, value) => MapEntry(key.toString(), value)),
            ),
          )
          .toList(growable: false);
    } on FormatException {
      return const [];
    }
  }

  @override
  Future<void> write(
    String userId,
    List<HomeNotification> notifications,
  ) async {
    final values = notifications.take(maxEntries).map(_mapper.toCacheRow);
    await (await SharedPreferences.getInstance()).setString(
      _feedKey(userId),
      jsonEncode(values.toList(growable: false)),
    );
  }

  @override
  Future<void> setRead(String userId, String id, {required bool isRead}) async {
    final values = await read(userId);
    await write(userId, [
      for (final item in values)
        item.id == id ? item.copyWith(isRead: isRead) : item,
    ]);
  }

  @override
  Future<void> remove(String userId, String id) async {
    await write(
      userId,
      (await read(userId)).where((item) => item.id != id).toList(),
    );
  }

  @override
  Future<Map<String, NotificationSyncAction>> pending(String userId) async {
    final value = (await SharedPreferences.getInstance()).getString(
      _pendingKey(userId),
    );
    if (value == null) return {};
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) return {};
      final result = <String, NotificationSyncAction>{};
      for (final entry in decoded.entries) {
        final action = NotificationSyncAction.values
            .where((item) => item.name == entry.value)
            .firstOrNull;
        if (action != null) result[entry.key.toString()] = action;
      }
      return result;
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> queue(
    String userId,
    String id,
    NotificationSyncAction action,
  ) async {
    final values = await pending(userId)
      ..[id] = action;
    await _writePending(userId, values);
  }

  @override
  Future<void> complete(String userId, String id) async {
    final values = await pending(userId)
      ..remove(id);
    await _writePending(userId, values);
  }

  Future<void> _writePending(
    String userId,
    Map<String, NotificationSyncAction> values,
  ) async {
    await (await SharedPreferences.getInstance()).setString(
      _pendingKey(userId),
      jsonEncode(values.map((key, value) => MapEntry(key, value.name))),
    );
  }

  String _feedKey(String userId) => 'agrisell.notification.feed.$userId.v1';
  String _pendingKey(String userId) => 'agrisell.notification.pending.$userId';
}
