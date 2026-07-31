import 'package:flutter/services.dart';

abstract final class DevicePhoneNumberService {
  static const _channel = MethodChannel('agrisell/device_phone_number');

  static Future<String?> requestNumber() async {
    try {
      return await _channel.invokeMethod<String>('requestPhoneNumber');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
