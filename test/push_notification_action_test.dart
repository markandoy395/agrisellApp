import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/services/push_notification_service.dart';

void main() {
  test('FCM data keeps the notification destination and recipient', () {
    final action = PushNotificationAction.fromData({
      'notification_id': '71',
      'destination': 'messages',
      'recipient_auth_user_id': 'user-1',
      'order_id': '14',
    });

    expect(action.notificationId, '71');
    expect(action.destination, 'messages');
    expect(action.recipientUserId, 'user-1');
    expect(action.orderId, '14');
  });

  test('invalid local notification payload has no navigation target', () {
    final action = PushNotificationAction.fromJson('not-json');

    expect(action.destination, 'none');
  });
}
