import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/firebase_options.dart';

part 'push_notification_action.dart';

@pragma('vm:entry-point')
Future<void> agrisellFirebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  PushNotificationService._();

  static final instance = PushNotificationService._();
  static const _channel = AndroidNotificationChannel(
    'agrisell_updates',
    'AgriSell updates',
    description: 'Orders, deliveries, messages, and account updates.',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final StreamController<PushNotificationAction> _actions =
      StreamController<PushNotificationAction>.broadcast();
  StreamSubscription<String>? _tokenRefreshSubscription;
  PushNotificationAction? _pendingAction;
  String? _userId;
  var _initialized = false;

  Stream<PushNotificationAction> get actions => _actions.stream;

  PushNotificationAction? takePendingAction() {
    final action = _pendingAction;
    _pendingAction = null;
    return action;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    FirebaseMessaging.onBackgroundMessage(
      agrisellFirebaseMessagingBackgroundHandler,
    );
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
        ),
        onDidReceiveNotificationResponse: (response) {
          final payload = response.payload;
          if (payload == null) return;
          _publishAction(PushNotificationAction.fromJson(payload));
        },
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) =>
          _publishAction(PushNotificationAction.fromData(message.data)),
    );
    unawaited(_loadInitialMessage());
    _initialized = true;
  }

  Future<void> registerForUser(String? userId) async {
    if (userId == null || userId.isEmpty || kIsWeb || Firebase.apps.isEmpty) {
      return;
    }
    _userId = userId;
    final recipient = _pendingAction?.recipientUserId;
    if (recipient != null && recipient != userId) {
      _pendingAction = null;
    }
    await _requestPermission();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) await _saveToken(userId, token);
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = FirebaseMessaging.instance.onTokenRefresh
        .listen((newToken) {
          final currentUserId = _userId;
          if (currentUserId != null) {
            unawaited(_saveToken(currentUserId, newToken));
          }
        });
  }

  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> _saveToken(String userId, String token) async {
    if (!AgrisellSupabase.isInitialized) return;
    try {
      await AgrisellSupabase.client.from('notification_devices').upsert({
        'user_id': userId,
        'fcm_token': token,
        'platform': defaultTargetPlatform.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }, onConflict: 'user_id,fcm_token');
    } on Object {
      // The next app start or token refresh retries registration.
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final title = message.notification?.title ?? _text(message.data['title']);
    final body = message.notification?.body ?? _text(message.data['body']);
    if (title.isEmpty && body.isEmpty) return;
    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1 << 31),
      title: title.isEmpty ? 'AgriSell' : title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'agrisell_updates',
          'AgriSell updates',
          channelDescription:
              'Orders, deliveries, messages, and account updates.',
          icon: 'ic_notification',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _loadInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _publishAction(PushNotificationAction.fromData(message.data));
    }
  }

  void _publishAction(PushNotificationAction? action) {
    if (action == null) return;
    final recipient = action.recipientUserId;
    if (recipient != null && _userId != null && recipient != _userId) return;
    _pendingAction = action;
    _actions.add(action);
  }

  String _text(Object? value) => value?.toString().trim() ?? '';
}
