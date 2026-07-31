import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:agresell_app/features/shared/notifications/domain/notification_category.dart';
import 'package:agresell_app/features/shared/orders/data/home_notification_cache.dart';
import 'package:agresell_app/features/shared/orders/domain/home_notification.dart';

void main() {
  const userId = 'auth-user';
  const cache = SharedPreferencesHomeNotificationCache();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('cached notifications survive repository instances', () async {
    final notification = _notification('101');
    await cache.write(userId, [notification]);

    final restored = await const SharedPreferencesHomeNotificationCache().read(
      userId,
    );

    expect(restored, hasLength(1));
    expect(restored.single.id, notification.id);
    expect(restored.single.metadata, {'delivery_id': 'delivery-1'});
    expect(restored.single.category, NotificationCategory.deliveries);
    expect(restored.single.type, HomeNotificationType.deliveryCompleted);
  });

  test('optimistic read and delete changes update the local feed', () async {
    await cache.write(userId, [_notification('101'), _notification('102')]);

    await cache.setRead(userId, '101', isRead: true);
    await cache.remove(userId, '102');

    final restored = await cache.read(userId);
    expect(restored, hasLength(1));
    expect(restored.single.id, '101');
    expect(restored.single.isRead, isTrue);
  });

  test('offline sync actions are durable and last action wins', () async {
    await cache.queue(userId, '101', NotificationSyncAction.read);
    await cache.queue(userId, '101', NotificationSyncAction.unread);
    await cache.queue(userId, '102', NotificationSyncAction.delete);

    final pending = await cache.pending(userId);
    expect(pending['101'], NotificationSyncAction.unread);
    expect(pending['102'], NotificationSyncAction.delete);

    await cache.complete(userId, '101');
    expect((await cache.pending(userId)).containsKey('101'), isFalse);
  });
}

HomeNotification _notification(String id) => HomeNotification(
  id: id,
  title: 'Delivery update',
  description: 'Your delivery changed.',
  image: '',
  imageLabel: 'Delivery',
  createdAt: DateTime.utc(2026, 7, 30),
  category: NotificationCategory.deliveries,
  type: HomeNotificationType.deliveryCompleted,
  destination: HomeNotificationDestination.deliveries,
  recipientId: 'auth-user',
  orderId: '42',
  metadata: const {'delivery_id': 'delivery-1'},
);
