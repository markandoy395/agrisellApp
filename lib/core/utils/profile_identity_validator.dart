import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/core/utils/profile_edit_validator.dart';

abstract final class ProfileIdentityValidator {
  static final _unsafeCommandPattern = RegExp(
    r'(<\s*script|javascript\s*:|data\s*:|onerror\s*=|onload\s*=|'
    r'\b(select|insert|update|delete|drop|alter|truncate|union|exec|execute)\b|'
    r'--|/\*|\*/|;)',
    caseSensitive: false,
  );
  static final _emailPattern = RegExp(r'^[^\s@<>;]+@[^\s@<>;]+\.[^\s@<>;]+$');

  static ProfileEditValidationResult validate({
    required UserProfile baseProfile,
    required String firstName,
    required String lastName,
    required String extensionName,
    required String phoneNumber,
    required ProfileBirthDate dateOfBirth,
    required String email,
  }) {
    final cleanFirstName = _clean(firstName);
    final cleanLastName = _clean(lastName);
    final cleanExtensionName = _clean(extensionName);
    final cleanPhone = _clean(phoneNumber);
    final cleanEmail = _clean(email);
    final error =
        _validateRequiredName('First Name', cleanFirstName) ??
        _validateRequiredName('Last Name', cleanLastName) ??
        _validateExtensionName(cleanExtensionName) ??
        _validatePhone(cleanPhone) ??
        _validateBirthDate(dateOfBirth) ??
        _validateEmail(cleanEmail);
    if (error != null) return ProfileEditValidationResult.invalid(error);

    final fullName = [
      cleanFirstName,
      cleanLastName,
      cleanExtensionName,
    ].where((part) => part.isNotEmpty).join(' ');
    return ProfileEditValidationResult.valid(
      baseProfile.copyWith(
        firstName: cleanFirstName,
        lastName: cleanLastName,
        extensionName: cleanExtensionName,
        name: fullName,
        phoneNumber: PhilippinePhoneNumber.display(
          PhilippinePhoneNumber.normalize(cleanPhone)!,
        ),
        dateOfBirth: dateOfBirth.formatted,
        email: cleanEmail,
      ),
    );
  }

  static String _clean(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String? _validateRequiredName(String label, String value) {
    if (value.isEmpty) return '$label is required.';
    return _validateText(label: label, value: value, maxLength: 60);
  }

  static String? _validateExtensionName(String value) {
    if (value.isEmpty) return null;
    return _validateText(label: 'Name Extension', value: value, maxLength: 20);
  }

  static String? _validatePhone(String value) {
    if (!PhilippinePhoneNumber.isValid(value)) {
      return 'Enter a valid mobile number (09XXXXXXXXX).';
    }
    return null;
  }

  static String? _validateBirthDate(ProfileBirthDate value) {
    final day = value.day;
    final month = value.month;
    final year = value.year;
    if (day == null || month == null || year == null) {
      return 'Date of Birth is required.';
    }
    final selected = DateTime(year, month, day);
    final now = DateTime.now();
    if (selected.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'Select a valid date of birth.';
    }
    return null;
  }

  static String? _validateEmail(String value) => _validateText(
    label: 'Email',
    value: value,
    maxLength: 80,
    pattern: _emailPattern,
  );

  static String? _validateText({
    required String label,
    required String value,
    required int maxLength,
    RegExp? pattern,
  }) {
    if (value.length > maxLength) return '$label is too long.';
    if (_unsafeCommandPattern.hasMatch(value)) {
      return 'Remove unsafe command-like text from $label.';
    }
    if (pattern != null && !pattern.hasMatch(value)) {
      return '$label contains invalid characters.';
    }
    return null;
  }
}
