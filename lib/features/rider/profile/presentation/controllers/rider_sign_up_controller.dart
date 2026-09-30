import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_availability_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_document_upload_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_submission_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';
part 'rider_sign_up_controller_actions.dart';

enum RiderFieldAvailability { idle, checking, available, unavailable }

class RiderSignUpController extends ChangeNotifier {
  RiderSignUpController({
    RiderSignUpDraftStorage? storage,
    RiderDocumentUploadService? documents,
    RiderSignUpAvailabilityService? availability,
    RiderSignUpSubmissionService? submission,
    GpsLocationGateway? gpsGateway,
  }) : _storage = storage ?? SharedPreferencesRiderSignUpDraftStorage(),
       _documents = documents ?? RiderDocumentUploadService(),
       _availabilityService = availability ?? RiderSignUpAvailabilityService(),
       _submissionService = submission ?? RiderSignUpSubmissionService(),
       _gpsGateway = gpsGateway ?? GeolocatorGpsLocationGateway();
  final RiderSignUpDraftStorage _storage;
  final RiderDocumentUploadService _documents;
  final RiderSignUpAvailabilityService _availabilityService;
  final RiderSignUpSubmissionService _submissionService;
  final GpsLocationGateway _gpsGateway;
  final _touched = <String>{};
  final _availability = <String, RiderFieldAvailability>{};
  final _availabilityTimers = <String, Timer>{};
  RiderSignUpDraft _draft = const RiderSignUpDraft();
  Timer? _saveTimer;
  String _password = '';
  String _confirmPassword = '';
  String _licenseNumber = '';
  bool _loading = true;
  bool _submitting = false;
  bool _capturingLocation = false;
  bool _showStepErrors = false;
  bool _awaitingEmailOtp = false;
  String? _verifiedEmail;
  String? _error;
  RiderSignUpDraft get draft => _draft;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  bool get isCapturingLocation => _capturingLocation;
  bool get awaitingEmailOtp => _awaitingEmailOtp;
  bool get emailVerified =>
      _verifiedEmail ==
      _draft.value(RiderSignUpFields.email).trim().toLowerCase();
  String? get errorMessage => _error;
  String get password => _password;
  String get confirmPassword => _confirmPassword;
  String get licenseNumber => _licenseNumber;
  RiderFieldAvailability availabilityFor(String field) =>
      _availability[field] ?? RiderFieldAvailability.idle;
  Future<void> initialize() async {
    try {
      _draft = await _storage.load() ?? const RiderSignUpDraft();
      for (final field in [RiderSignUpFields.mobile, RiderSignUpFields.email]) {
        final value = _draft.value(field);
        if (value.isNotEmpty) _checkAvailability(field, value);
      }
    } catch (_) {
      _error = 'Your saved Rider Sign-Up could not be restored.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

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
    notifyListeners();
  }

  static const _addressFields = {
    RiderSignUpFields.addressLine,
    RiderSignUpFields.province,
    RiderSignUpFields.cityMunicipality,
    RiderSignUpFields.barangay,
    RiderSignUpFields.postalCode,
  };

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
    notifyListeners();
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
    notifyListeners();
  }

  void markEmailVerified(String email) {
    _verifiedEmail = email.trim().toLowerCase();
    _availability[RiderSignUpFields.email] = RiderFieldAvailability.available;
    _error = null;
    notifyListeners();
  }

  void showEmailVerificationError(String message) {
    _error = message;
    notifyListeners();
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
    notifyListeners();
  }

  void updateAgreement({bool? terms, bool? privacy, bool? accuracy}) {
    _draft = _draft.copyWith(
      acceptsTerms: terms,
      acceptsPrivacy: privacy,
      confirmsAccuracy: accuracy,
    );
    _queueSave();
    notifyListeners();
  }

  String? errorFor(String field) {
    if (!_showStepErrors && !_touched.contains(field)) return null;
    return RiderSignUpValidator.fieldError(field, _draft.value(field), _draft);
  }

  bool get canContinue {
    final error = RiderSignUpValidator.stepError(
      draft: _draft,
      step: _draft.step,
      licenseNumber: _licenseNumber,
      password: _password,
      confirmPassword: _confirmPassword,
      requireCoordinates: _draft.step != RiderSignUpStep.address,
      requirePassword: !emailVerified,
    );
    final checking = switch (_draft.step) {
      RiderSignUpStep.account =>
        !emailVerified &&
            availabilityFor(RiderSignUpFields.email) ==
                RiderFieldAvailability.checking,
      RiderSignUpStep.personal =>
        availabilityFor(RiderSignUpFields.mobile) !=
            RiderFieldAvailability.available,
      _ => false,
    };
    return error == null && !checking;
  }

  Future<bool> continueToNextStep() async {
    if (!canContinue) {
      _showStepErrors = true;
      notifyListeners();
      return false;
    }
    if (_draft.step == RiderSignUpStep.address &&
        !await _captureCurrentLocation()) {
      _showStepErrors = true;
      notifyListeners();
      return false;
    }
    final nextIndex = _draft.step.index + 1;
    if (nextIndex >= RiderSignUpStep.values.length) return true;
    _draft = _draft.copyWith(step: RiderSignUpStep.values[nextIndex]);
    _showStepErrors = false;
    await saveNow();
    notifyListeners();
    return true;
  }

  Future<bool> _captureCurrentLocation() async {
    if (_capturingLocation) return false;
    _capturingLocation = true;
    _error = null;
    notifyListeners();
    try {
      if (!await _gpsGateway.isServiceEnabled()) {
        await _gpsGateway.openLocationSettings();
        _error = 'Turn on location services, then try continuing again.';
        return false;
      }
      var permission = await _gpsGateway.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _gpsGateway.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        _error = 'Allow location access so we can capture your exact location.';
        return false;
      }
      if (permission == LocationPermission.deniedForever) {
        await _gpsGateway.openAppSettings();
        _error =
            'Allow location permission in app settings, then try continuing again.';
        return false;
      }
      if (await _gpsGateway.getAccuracyStatus() ==
          LocationAccuracyStatus.reduced) {
        await _gpsGateway.openAppSettings();
        _error = 'Enable precise location, then try continuing again.';
        return false;
      }
      final position = await _gpsGateway.currentPosition(
        settings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 15),
        ),
      );
      updateLocation(
        label: _addressLabel(),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: position.timestamp,
      );
      return true;
    } on TimeoutException {
      _error = 'Location capture timed out. Please try continuing again.';
      return false;
    } catch (_) {
      _error = 'We could not capture your exact location. Please try again.';
      return false;
    } finally {
      _capturingLocation = false;
      notifyListeners();
    }
  }

  String _addressLabel() => RiderAddress.format(
    addressLine: _draft.value(RiderSignUpFields.addressLine),
    barangay: _draft.value(RiderSignUpFields.barangay),
    cityMunicipality: _draft.value(RiderSignUpFields.cityMunicipality),
    province: _draft.value(RiderSignUpFields.province),
    postalCode: _draft.value(RiderSignUpFields.postalCode),
  );

  Future<void> previousStep() async {
    if (_draft.step == RiderSignUpStep.account) return;
    _draft = _draft.copyWith(
      step: RiderSignUpStep.values[_draft.step.index - 1],
    );
    _showStepErrors = false;
    await saveNow();
    notifyListeners();
  }

  Future<void> editStep(RiderSignUpStep step) async {
    _draft = _draft.copyWith(step: step);
    _showStepErrors = false;
    await saveNow();
    notifyListeners();
  }

  Future<void> resumeVerifiedEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    _draft = _draft.withValue(RiderSignUpFields.email, normalizedEmail);
    if (_draft.step == RiderSignUpStep.account) {
      _draft = _draft.copyWith(step: RiderSignUpStep.personal);
    }
    markEmailVerified(normalizedEmail);
    await saveNow();
  }

  void _queueSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), saveNow);
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
    notifyListeners();
  }

  void _refresh() => notifyListeners();
  @override
  void dispose() {
    _saveTimer?.cancel();
    for (final timer in _availabilityTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
