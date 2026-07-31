part of 'push_notification_service.dart';

class PushNotificationAction {
  const PushNotificationAction({
    required this.notificationId,
    required this.destination,
    this.recipientUserId,
    this.orderId,
  });

  factory PushNotificationAction.fromData(Map<String, dynamic> data) {
    return _fromValues(data);
  }

  factory PushNotificationAction.fromJson(String source) {
    try {
      final values = jsonDecode(source);
      if (values is Map) {
        return _fromValues({
          for (final entry in values.entries)
            entry.key.toString(): entry.value.toString(),
        });
      }
    } on FormatException {
      // An invalid local payload does not have a safe navigation target.
    }
    return const PushNotificationAction(
      notificationId: '',
      destination: 'none',
    );
  }

  static PushNotificationAction _fromValues(Map<String, Object?> values) {
    return PushNotificationAction(
      notificationId: values['notification_id']?.toString() ?? '',
      destination: values['destination']?.toString() ?? 'none',
      recipientUserId: values['recipient_auth_user_id']?.toString(),
      orderId: values['order_id']?.toString(),
    );
  }

  final String notificationId;
  final String destination;
  final String? recipientUserId;
  final String? orderId;
}
