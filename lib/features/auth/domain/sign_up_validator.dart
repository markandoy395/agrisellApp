import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/core/utils/written_address.dart';

abstract final class SignUpValidator {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? validate({
    required String firstName,
    required String lastName,
    required String contactNumber,
    required String dateOfBirth,
    required String gender,
    required String shippingAddress,
    required String email,
    required String password,
    required String confirmPassword,
    required bool agreesToPolicy,
  }) {
    if (firstName.isEmpty) {
      return 'Enter your first name.';
    }
    if (lastName.isEmpty) {
      return 'Enter your last name.';
    }
    if (!PhilippinePhoneNumber.isValid(contactNumber)) {
      return 'Enter a valid mobile number (09XXXXXXXXX).';
    }
    final birthDate = DateTime.tryParse(dateOfBirth);
    final today = DateTime.now();
    final currentDate = DateTime(today.year, today.month, today.day);
    if (birthDate == null || birthDate.isAfter(currentDate)) {
      return 'Select a valid date of birth.';
    }
    if (gender.isEmpty) return 'Select your gender.';
    if (!WrittenAddress.isValid(shippingAddress)) {
      return 'Enter your shipping address.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    if (password.isEmpty) return 'Enter your password.';
    if (!PasswordPolicy.isStrong(password)) return 'Password is too weak.';
    if (password != confirmPassword) {
      return 'Password and confirm password must match.';
    }
    if (!agreesToPolicy) {
      return 'Agree to the privacy and policy before signing up.';
    }

    return null;
  }
}
