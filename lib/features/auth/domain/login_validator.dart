class LoginValidator {
  const LoginValidator._();

  static String? validateIdentifier(String value) {
    final identifier = value.trim();
    if (identifier.isEmpty) {
      return 'Email or phone number is required.';
    }
    if (_isEmail(identifier) || _isPhone(identifier)) {
      return null;
    }
    return 'Enter a valid email address or mobile number.';
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) return 'Password is required.';
    return null;
  }

  static bool _isEmail(String value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value);

  static bool _isPhone(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 10 && digits.length <= 15;
  }
}
