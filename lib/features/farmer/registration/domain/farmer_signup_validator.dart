import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/farmer/registration/domain/philippine_crops.dart';

abstract final class FarmerSignupValidator {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? email(String value) =>
      _email.hasMatch(value.trim()) ? null : 'Enter a valid email address.';

  static String? password(String value) => PasswordPolicy.isStrong(value)
      ? null
      : 'Use a stronger password with at least 8 characters.';

  static String? passwordConfirmation(String password, String confirmation) =>
      password == confirmation ? null : 'Passwords do not match.';

  static String? required(String value, String label) =>
      value.trim().isEmpty ? 'Enter $label.' : null;

  static String? choice(String value, List<String> choices, String label) =>
      choices.contains(value.trim()) ? null : 'Select $label.';

  static String? optionalChoice(
    String value,
    List<String> choices,
    String label,
  ) => value.trim().isEmpty ? null : choice(value, choices, label);

  static String? mainCrops(String value) {
    final selected = PhilippineCrops.parseSelection(value);
    if (selected.isEmpty) return 'Choose at least one main crop.';
    if (selected.any((crop) => !PhilippineCrops.names.contains(crop))) {
      return 'Choose crops from the list.';
    }
    return null;
  }

  static String? phone(String value) => PhilippinePhoneNumber.isValid(value)
      ? null
      : 'Enter a valid mobile number (09XXXXXXXXX).';

  static String? dateOfBirth(String value) {
    if (value.trim().isEmpty) return 'Select your date of birth.';
    final date = DateTime.tryParse(value);
    if (date == null || date.isAfter(DateTime.now())) {
      return 'Select a valid date of birth.';
    }
    return null;
  }

  static String? number(String value, String label) {
    if (value.trim().isEmpty) return 'Enter $label.';
    final parsed = double.tryParse(value);
    return parsed == null || !parsed.isFinite || parsed <= 0
        ? 'Enter a valid $label.'
        : null;
  }

  static String? wholeNumber(String value, String label) {
    if (value.trim().isEmpty) return 'Enter $label.';
    final parsed = int.tryParse(value);
    return parsed == null || parsed < 0
        ? 'Enter a whole number for $label.'
        : null;
  }

  static String? farmCoordinates(String latitude, String longitude) {
    if (latitude.trim().isEmpty || longitude.trim().isEmpty) {
      return 'Allow location access so we can capture your farm location.';
    }
    final parsedLatitude = double.tryParse(latitude);
    final parsedLongitude = double.tryParse(longitude);
    if (parsedLatitude == null ||
        parsedLongitude == null ||
        !parsedLatitude.isFinite ||
        !parsedLongitude.isFinite ||
        parsedLatitude < -90 ||
        parsedLatitude > 90 ||
        parsedLongitude < -180 ||
        parsedLongitude > 180) {
      return 'Choose a valid farm location.';
    }
    return null;
  }
}
