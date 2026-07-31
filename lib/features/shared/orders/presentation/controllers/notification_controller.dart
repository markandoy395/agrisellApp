import 'package:flutter/foundation.dart';

import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

class NotificationController extends ChangeNotifier {
  NotificationController();

  final Set<String> _readIds = <String>{};
  final Set<String> _unreadIds = <String>{};
  final Set<String> _deletedIds = <String>{};

  bool isRead(HomeNotification notification) {
    if (_unreadIds.contains(notification.id)) return false;
    return notification.isRead || _readIds.contains(notification.id);
  }

  bool isDeleted(HomeNotification notification) {
    return _deletedIds.contains(notification.id);
  }

  void markRead(HomeNotification notification) {
    if (isRead(notification) || notification.id.isEmpty) return;
    _unreadIds.remove(notification.id);
    _readIds.add(notification.id);
    notifyListeners();
  }

  void markUnread(HomeNotification notification) {
    if (!isRead(notification) || notification.id.isEmpty) return;
    _readIds.remove(notification.id);
    _unreadIds.add(notification.id);
    notifyListeners();
  }

  void markAllRead(Iterable<HomeNotification> notifications) {
    var changed = false;
    for (final notification in notifications) {
      if (notification.id.isEmpty || isRead(notification)) continue;
      _unreadIds.remove(notification.id);
      _readIds.add(notification.id);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void delete(HomeNotification notification) {
    if (notification.id.isEmpty || isDeleted(notification)) return;
    _deletedIds.add(notification.id);
    notifyListeners();
  }

  void clear(Iterable<HomeNotification> notifications) {
    final ids = notifications
        .map((notification) => notification.id)
        .where((id) => id.isNotEmpty);
    final previousLength = _deletedIds.length;
    _deletedIds.addAll(ids);
    if (_deletedIds.length != previousLength) notifyListeners();
  }
}
