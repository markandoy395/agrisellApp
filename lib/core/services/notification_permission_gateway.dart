import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NotificationPermissionState { unavailable, requestable, enabled, blocked }

abstract class NotificationPermissionGateway {
  Future<NotificationPermissionState> read();
  Future<NotificationPermissionState> request();
  Future<bool> hasOffered();
  Future<void> markOffered();
  Future<bool> openSettings();
}

class DeviceNotificationPermissionGateway
    implements NotificationPermissionGateway {
  static final instance = DeviceNotificationPermissionGateway();
  static const _channel = MethodChannel('agrisell/notification_settings');
  static const _askedKey = 'notification_permission_requested';
  static const _offeredKey = 'notification_permission_offered';

  bool get _supported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      Firebase.apps.isNotEmpty;

  @override
  Future<NotificationPermissionState> read() async {
    if (!_supported) return NotificationPermissionState.unavailable;
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return NotificationPermissionState.enabled;
    }
    // Android reports denied before the first request as well as after denial.
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_askedKey) == true
        ? NotificationPermissionState.blocked
        : NotificationPermissionState.requestable;
  }

  @override
  Future<NotificationPermissionState> request() async {
    if (await read() != NotificationPermissionState.requestable) return read();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_askedKey, true);
    // One API owns the OS prompt; local notifications share this permission.
    await FirebaseMessaging.instance.requestPermission();
    return read();
  }

  @override
  Future<bool> hasOffered() async =>
      (await SharedPreferences.getInstance()).getBool(_offeredKey) == true;

  @override
  Future<void> markOffered() async {
    await (await SharedPreferences.getInstance()).setBool(_offeredKey, true);
  }

  @override
  Future<bool> openSettings() async =>
      await _channel.invokeMethod<bool>('openNotificationSettings') ?? false;
}
