part of 'rider_sign_up_controller.dart';

extension RiderSignUpControllerFields on RiderSignUpController {
  static const _addressFields = {
    RiderSignUpFields.addressLine,
    RiderSignUpFields.province,
    RiderSignUpFields.cityMunicipality,
    RiderSignUpFields.barangay,
    RiderSignUpFields.postalCode,
  };

  void updateValue(String field, String value) {
    if (_draft.value(field) == value) return;
    if (field == RiderSignUpFields.email &&
        value.trim().toLowerCase() != _verifiedEmail) {
      _verifiedEmail = null;
    }
    _draft = _draft.withValue(field, value);
    if (_addressFields.contains(field)) _clearCapturedLocation();
    _touched.add(field);
    _showStepErrors = false;
    _queueSave();
    if (field == RiderSignUpFields.email || field == RiderSignUpFields.mobile) {
      _checkAvailability(field, value);
    }
    _refresh();
  }

  void updateAddress({
    required String addressLine,
    required String province,
    required String cityMunicipality,
    required String barangay,
    required String postalCode,
    required String location,
  }) {
    final values = <String, String>{
      RiderSignUpFields.addressLine: addressLine,
      RiderSignUpFields.province: province,
      RiderSignUpFields.cityMunicipality: cityMunicipality,
      RiderSignUpFields.barangay: barangay,
      RiderSignUpFields.postalCode: postalCode,
      RiderSignUpFields.location: location,
    };
    final changed = values.entries
        .where((entry) => _draft.value(entry.key) != entry.value)
        .toList();
    if (changed.isEmpty) return;
    _draft = _draft.copyWith(values: {..._draft.values, ...values});
    if (changed.any((entry) => _addressFields.contains(entry.key))) {
      _clearCapturedLocation();
    }
    _touched.addAll(changed.map((entry) => entry.key));
    _showStepErrors = false;
    _queueSave();
    _refresh();
  }

  void _clearCapturedLocation() {
    _draft = _draft.copyWith(
      values: {
        ..._draft.values,
        RiderSignUpFields.latitude: '',
        RiderSignUpFields.longitude: '',
        RiderSignUpFields.locationAccuracy: '',
        RiderSignUpFields.locationCapturedAt: '',
        RiderSignUpFields.locationNotes: '',
      },
    );
  }

  void updateSensitive({
    String? password,
    String? confirmPassword,
    String? licenseNumber,
  }) {
    if (password != null) _password = password;
    if (confirmPassword != null) _confirmPassword = confirmPassword;
    if (licenseNumber != null) _licenseNumber = licenseNumber;
    _refresh();
  }

  void markEmailVerified(String email) {
    _verifiedEmail = email.trim().toLowerCase();
    _availability[RiderSignUpFields.email] = RiderFieldAvailability.available;
    _error = null;
    _refresh();
  }

  void showEmailVerificationError(String message) {
    _error = message;
    _refresh();
  }

  void updateLocation({
    required String label,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    required DateTime capturedAt,
    String? notes,
  }) {
    _draft = _draft
        .withValue(RiderSignUpFields.location, label)
        .withValue(RiderSignUpFields.latitude, '$latitude')
        .withValue(RiderSignUpFields.longitude, '$longitude')
        .withValue(RiderSignUpFields.locationAccuracy, '$accuracyMeters')
        .withValue(
          RiderSignUpFields.locationCapturedAt,
          capturedAt.toUtc().toIso8601String(),
        )
        .withValue(RiderSignUpFields.locationNotes, notes ?? '');
    _queueSave();
    _refresh();
  }

  void updateAgreement({bool? terms, bool? privacy, bool? accuracy}) {
    _draft = _draft.copyWith(
      acceptsTerms: terms,
      acceptsPrivacy: privacy,
      confirmsAccuracy: accuracy,
    );
    _queueSave();
    _refresh();
  }

  String? errorFor(String field) {
    if (!_showStepErrors && !_touched.contains(field)) return null;
    return RiderSignUpValidator.fieldError(field, _draft.value(field), _draft);
  }

  void _checkAvailability(String field, String value) {
    _availabilityTimers[field]?.cancel();
    _availability[field] = RiderFieldAvailability.checking;
    _availabilityTimers[field] = Timer(
      const Duration(milliseconds: 450),
      () => _resolveAvailability(field, value),
    );
  }

  Future<void> _resolveAvailability(String field, String value) async {
    final available = field == RiderSignUpFields.email
        ? await _availabilityService.isEmailAvailable(value)
        : await _availabilityService.isMobileAvailable(value);
    if (_draft.value(field) != value) return;
    _availability[field] = available
        ? RiderFieldAvailability.available
        : RiderFieldAvailability.unavailable;
    _refresh();
  }
}
