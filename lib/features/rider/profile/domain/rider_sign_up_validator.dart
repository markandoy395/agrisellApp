import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration_validator.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';

abstract final class RiderSignUpFields {
  static const firstName = 'firstName';
  static const middleName = 'middleName';
  static const lastName = 'lastName';
  static const dateOfBirth = 'dateOfBirth';
  static const gender = 'gender';
  static const mobile = 'mobile';
  static const email = 'email';
  static const location = 'location';
  static const addressLine = 'addressLine';
  static const province = 'province';
  static const cityMunicipality = 'cityMunicipality';
  static const barangay = 'barangay';
  static const postalCode = 'postalCode';
  static const latitude = 'latitude';
  static const longitude = 'longitude';
  static const locationAccuracy = 'locationAccuracy';
  static const locationCapturedAt = 'locationCapturedAt';
  static const locationNotes = 'locationNotes';
  static const vehicleType = 'vehicleType';
  static const plate = 'plate';
  static const logisticsCompanyId = 'logisticsCompanyId';
  static const logisticsCompanyName = 'logisticsCompanyName';
}

abstract final class RiderSignUpValidator {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _mobile = RegExp(r'^(?:\+63|0)9\d{9}$');

  static String? fieldError(String key, String value, RiderSignUpDraft draft) {
    final clean = value.trim();
    return switch (key) {
      RiderSignUpFields.firstName when clean.isEmpty =>
        'First name is required.',
      RiderSignUpFields.lastName when clean.isEmpty => 'Last name is required.',
      RiderSignUpFields.dateOfBirth when !_isAdult(clean) =>
        'You must meet the minimum rider age requirement.',
      RiderSignUpFields.gender when clean.isEmpty => 'Select a gender.',
      RiderSignUpFields.mobile when !_mobile.hasMatch(_phone(clean)) =>
        'Enter a valid mobile number.',
      RiderSignUpFields.email when !_email.hasMatch(clean) =>
        'Enter a valid email address.',
      RiderSignUpFields.location when !WrittenAddress.isValid(clean) =>
        'Enter your written address.',
      RiderSignUpFields.addressLine when clean.isEmpty =>
        'Enter your house, building, or street address.',
      RiderSignUpFields.province when clean.isEmpty => 'Select your province.',
      RiderSignUpFields.cityMunicipality when clean.isEmpty =>
        'Select your city or municipality.',
      RiderSignUpFields.barangay when clean.isEmpty => 'Select your barangay.',
      RiderSignUpFields.vehicleType when _vehicle(draft) == null =>
        'Select a vehicle type.',
      RiderSignUpFields.plate when _requiresPlate(draft) && clean.isEmpty =>
        'Enter the vehicle plate number.',
      _ => null,
    };
  }

  static String? stepError({
    required RiderSignUpDraft draft,
    required RiderSignUpStep step,
    required String licenseNumber,
    required String password,
    required String confirmPassword,
    bool requireCoordinates = true,
  }) {
    final fields = switch (step) {
      RiderSignUpStep.personal => [
        RiderSignUpFields.firstName,
        RiderSignUpFields.lastName,
        RiderSignUpFields.dateOfBirth,
        RiderSignUpFields.gender,
        RiderSignUpFields.mobile,
        RiderSignUpFields.email,
      ],
      RiderSignUpStep.address => [
        RiderSignUpFields.addressLine,
        RiderSignUpFields.province,
        RiderSignUpFields.cityMunicipality,
        RiderSignUpFields.barangay,
      ],
      RiderSignUpStep.vehicle => [
        RiderSignUpFields.vehicleType,
        RiderSignUpFields.plate,
      ],
      RiderSignUpStep.documents ||
      RiderSignUpStep.security ||
      RiderSignUpStep.review => const <String>[],
    };
    for (final field in fields) {
      final error = fieldError(field, draft.value(field), draft);
      if (error != null) return error;
    }
    if (step == RiderSignUpStep.address &&
        requireCoordinates &&
        !hasValidCoordinates(draft)) {
      return 'Allow location access so we can capture your exact location.';
    }
    if (step == RiderSignUpStep.documents &&
        _requiresLicense(draft) &&
        licenseNumber.trim().isEmpty) {
      return 'Enter your driver\'s license number.';
    }
    if (step == RiderSignUpStep.documents) {
      final requiredDocuments = <RiderDraftDocumentType>[
        RiderDraftDocumentType.validId,
        if (_requiresLicense(draft)) RiderDraftDocumentType.driversLicense,
        if (_requiresPlate(draft)) ...[
          RiderDraftDocumentType.vehicleOr,
          RiderDraftDocumentType.vehicleCr,
          RiderDraftDocumentType.vehiclePhoto,
        ],
      ];
      final missing = requiredDocuments
          .where((type) => draft.documents[type] == null)
          .firstOrNull;
      if (missing != null) return 'Upload your ${missing.label}.';
    }
    if (step == RiderSignUpStep.security) {
      if (!RiderRegistrationValidator.isStrongPassword(password)) {
        return 'Password is too weak.';
      }
      if (password != confirmPassword) return 'Passwords do not match.';
    }
    if (step == RiderSignUpStep.review &&
        (!draft.acceptsTerms ||
            !draft.acceptsPrivacy ||
            !draft.confirmsAccuracy)) {
      return 'Complete all agreements before submitting.';
    }
    return null;
  }

  static RiderVehicleType? _vehicle(RiderSignUpDraft draft) => RiderVehicleType
      .values
      .where((type) => type.name == draft.value(RiderSignUpFields.vehicleType))
      .firstOrNull;
  static bool _requiresPlate(RiderSignUpDraft draft) =>
      _vehicle(draft)?.requiresPlate ?? false;
  static bool _requiresLicense(RiderSignUpDraft draft) =>
      _vehicle(draft)?.requiresLicense ?? false;
  static String _phone(String value) => value.replaceAll(RegExp(r'[ -]'), '');

  static bool hasValidCoordinates(RiderSignUpDraft draft) {
    final latitude = double.tryParse(draft.value(RiderSignUpFields.latitude));
    final longitude = double.tryParse(draft.value(RiderSignUpFields.longitude));
    return latitude != null &&
        longitude != null &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  static bool _isAdult(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return false;
    final now = DateTime.now();
    var age = now.year - date.year;
    if (DateTime(now.year, date.month, date.day).isAfter(now)) age--;
    return age >= 18;
  }
}
