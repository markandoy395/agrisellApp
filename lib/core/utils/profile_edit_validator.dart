import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/written_address.dart';

class ProfileEditValidationResult {
  const ProfileEditValidationResult.valid(this.profile) : errorMessage = null;
  const ProfileEditValidationResult.invalid(this.errorMessage) : profile = null;

  final UserProfile? profile;
  final String? errorMessage;
}

abstract final class ProfileEditValidator {
  static const imageRequirementMessage =
      'Allowed images: JPG, PNG, WEBP up to 5 MB.';
  static const maxProfileImageBytes = 5 * 1024 * 1024;
  static const allowedImageExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  static final _unsafeCommandPattern = RegExp(
    r'(<\s*script|javascript\s*:|data\s*:|onerror\s*=|onload\s*=|'
    r'\b(select|insert|update|delete|drop|alter|truncate|union|exec|execute)\b|'
    r'--|/\*|\*/|;)',
    caseSensitive: false,
  );
  static final _emailPattern = RegExp(r'^[^\s@<>;]+@[^\s@<>;]+\.[^\s@<>;]+$');
  static final _addressPattern = RegExp(r'^[A-Za-z0-9 ,.\/#-]+$');
  static final _blockedImageNamePattern = RegExp(
    r'\.(apk|bat|cmd|dll|exe|html?|jar|js|msi|php|sh|svg)(\.|$)',
    caseSensitive: false,
  );
  static final _unsafeFileNamePattern = RegExp(r'[\\/:*?"<>|]');

  static ProfileEditValidationResult validateProfile({
    required UserProfile baseProfile,
    required String name,
    required String email,
    required String address,
    required String phoneNumber,
  }) {
    final cleanName = _clean(name);
    final cleanEmail = _clean(email);
    final cleanAddress = _clean(address);
    final cleanPhone = _clean(phoneNumber);
    final error =
        _validateName(cleanName) ??
        _validateEmail(cleanEmail) ??
        _validateAddress(cleanAddress) ??
        _validatePhone(cleanPhone);

    if (error != null) return ProfileEditValidationResult.invalid(error);

    return ProfileEditValidationResult.valid(
      baseProfile.copyWith(
        name: cleanName,
        email: cleanEmail,
        address: cleanAddress,
        phoneNumber: PhilippinePhoneNumber.normalize(cleanPhone)!,
      ),
    );
  }

  static String? validateProfileImage({
    required String fileName,
    required int fileSizeBytes,
  }) {
    final cleanFileName = fileName.trim();
    if (cleanFileName.isEmpty) return 'Please choose an image file.';
    if (_unsafeFileNamePattern.hasMatch(cleanFileName) ||
        _blockedImageNamePattern.hasMatch(cleanFileName) ||
        _hasUnsafeContent(cleanFileName)) {
      return 'Choose a safe image file name.';
    }

    final extension = cleanFileName.split('.').last.toLowerCase();
    if (!allowedImageExtensions.contains(extension)) {
      return 'Only JPG, PNG, or WEBP images are allowed.';
    }
    if (fileSizeBytes <= 0) return 'Image file is empty.';
    if (fileSizeBytes > maxProfileImageBytes) {
      return 'Profile image must be 5 MB or smaller.';
    }
    return null;
  }

  static String _clean(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool _hasUnsafeContent(String value) {
    return _unsafeCommandPattern.hasMatch(value);
  }

  static String? _validateName(String value) {
    return _validateText(label: 'Name', value: value, minLength: 2);
  }

  static String? _validateEmail(String value) {
    return _validateText(
      label: 'Email',
      value: value,
      maxLength: 80,
      pattern: _emailPattern,
    );
  }

  static String? _validateAddress(String value) {
    if (!WrittenAddress.isValid(value)) {
      return 'Enter a written address, not latitude and longitude.';
    }
    return _validateText(
      label: 'Address',
      value: value,
      minLength: 5,
      maxLength: 100,
      pattern: _addressPattern,
    );
  }

  static String? _validatePhone(String value) {
    if (value.isEmpty) return 'Phone Number is required.';
    if (_hasUnsafeContent(value) || !PhilippinePhoneNumber.isValid(value)) {
      return 'Enter a valid mobile number (09XXXXXXXXX).';
    }
    return null;
  }

  static String? _validateText({
    required String label,
    required String value,
    int minLength = 1,
    int maxLength = 60,
    RegExp? pattern,
  }) {
    if (value.isEmpty) return '$label is required.';
    if (value.length < minLength) return '$label is too short.';
    if (value.length > maxLength) return '$label is too long.';
    if (_hasUnsafeContent(value)) {
      return 'Remove unsafe command-like text from $label.';
    }
    if (pattern != null && !pattern.hasMatch(value)) {
      return '$label contains invalid characters.';
    }
    return null;
  }
}
