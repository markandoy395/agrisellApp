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
part 'rider_sign_up_controller_fields.dart';
part 'rider_sign_up_controller_steps.dart';

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

  void _queueSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 450), saveNow);
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
