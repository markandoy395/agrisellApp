import 'package:flutter/services.dart';

abstract final class PhilippinePhoneNumber {
  static final _validPattern = RegExp(r'^(?:09\d{9}|\+639\d{9})$');

  static bool isValid(String value) => _validPattern.hasMatch(_compact(value));

  static String? normalize(String value) {
    final compact = _compact(value);
    if (!_validPattern.hasMatch(compact)) return null;
    return compact.startsWith('09') ? '+63${compact.substring(1)}' : compact;
  }

  /// Normalizes common formats returned by Android's SIM phone-number picker.
  static String? normalizeDeviceNumber(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    final nationalMatch = RegExp(r'09\d{9}').firstMatch(digits);
    if (nationalMatch != null) return normalize(nationalMatch.group(0)!);

    final subscriberMatch = RegExp(r'9\d{9}').firstMatch(digits);
    if (subscriberMatch == null) return null;
    return normalize('+63${subscriberMatch.group(0)!}');
  }

  /// Formats stored values for the Philippine-only app interface.
  static String display(String value) {
    final compact = _compact(value);
    return compact.startsWith('+63') ? '0${compact.substring(3)}' : compact;
  }

  static String _compact(String value) =>
      value.trim().replaceAll(RegExp(r'[\s()\-]'), '');
}

class PhilippinePhoneNumberInputFormatter extends TextInputFormatter {
  const PhilippinePhoneNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final startsWithPlus = newValue.text.trimLeft().startsWith('+');
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final maxDigits = startsWithPlus ? 12 : 11;
    final clipped = digits.length > maxDigits
        ? digits.substring(0, maxDigits)
        : digits;
    final text = startsWithPlus ? '+$clipped' : clipped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
