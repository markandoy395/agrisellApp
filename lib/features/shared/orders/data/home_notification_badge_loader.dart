import 'package:agresell_app/features/auth/domain/signUpAccountData.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_repository.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';
import 'package:agresell_app/features/shared/orders/presentation/controllers/order_controller.dart';

Future<int> loadUnreadHomeNotificationCount({
  required AuthRole role,
  String? userId,
}) async {
  var databaseNotifications = const <HomeNotification>[];
  try {
    databaseNotifications = await const HomeNotificationRepository()
        .loadForUser(userId);
  } on Object {
    // Local order updates remain available while the backend is unavailable.
  }

  return _unreadCount(
    role: role,
    userId: userId,
    databaseNotifications: databaseNotifications,
  );
}

Future<int> loadCachedUnreadHomeNotificationCount({
  required AuthRole role,
  String? userId,
}) async {
  final notifications = await const HomeNotificationRepository()
      .loadCachedForUser(userId);
  return _unreadCount(
    role: role,
    userId: userId,
    databaseNotifications: notifications,
  );
}

int _unreadCount({
  required AuthRole role,
  required String? userId,
  required List<HomeNotification> databaseNotifications,
}) {
  final orderController = OrderController.instance;
  return [
    ...orderController.orderNotifications,
    ...databaseNotifications,
  ].where((notification) {
    return notification.isVisibleTo(role, userId: userId) &&
        !orderController.isNotificationRead(notification);
  }).length;
}
