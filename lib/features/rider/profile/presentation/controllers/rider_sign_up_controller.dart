import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_availability_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_document_upload_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_draft_storage.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_submission_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
part 'rider_sign_up_controller_actions.dart';

enum RiderFieldAvailability { idle, checking, available, unavailable }

class RiderSignUpController extends ChangeNotifier {
  RiderSignUpController({
    RiderSignUpDraftStorage? storage,
    RiderDocumentUploadService? documents,
    RiderSignUpAvailabilityService? availability,
    RiderSignUpSubmissionService? submission,
  }) : _storage = storage ?? SharedPreferencesRiderSignUpDraftStorage(),
       _documents = documents ?? RiderDocumentUploadService(),
       _availabilityService = availability ?? RiderSignUpAvailabilityService(),
       _submissionService = submission ?? RiderSignUpSubmissionService();
  final RiderSignUpDraftStorage _storage;
  final RiderDocumentUploadService _documents;
  final RiderSignUpAvailabilityService _availabilityService;
  final RiderSignUpSubmissionService _submissionService;
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
  bool _showStepErrors = false;
  bool _awaitingEmailOtp = false;
  String? _error;
  RiderSignUpDraft get draft => _draft;
  bool get isLoading => _loading;
  bool get isSubmitting => _submitting;
  bool get awaitingEmailOtp => _awaitingEmailOtp;
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
    _draft = _draft.withValue(field, value);
    _touched.add(field);
    _showStepErrors = false;
    _queueSave();
    if (field == RiderSignUpFields.email || field == RiderSignUpFields.mobile) {
      _checkAvailability(field, value);
    }
    notifyListeners();
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
    );
    final checking =
        _draft.step == RiderSignUpStep.personal &&
        [RiderSignUpFields.mobile, RiderSignUpFields.email].any(
          (field) => availabilityFor(field) != RiderFieldAvailability.available,
        );
    return error == null && !checking;
  }

  Future<bool> continueToNextStep() async {
    if (!canContinue) {
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

  Future<void> previousStep() async {
    if (_draft.step == RiderSignUpStep.personal) return;
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
