import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_exceptions.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_payload.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_exception.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';
import 'package:agresell_app/features/rider/profile/data/rider_sign_up_submission_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration_validator.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';

export 'package:agresell_app/features/rider/profile/data/rider_registration_exceptions.dart';

part 'rider_registration_service_remote.dart';
part 'rider_registration_service_documents.dart';
part 'rider_profile_entity_mapper.dart';
part 'rider_registration_service_profile_updater.dart';

class RiderRegistrationService extends ChangeNotifier {
  RiderRegistrationService._();
  static final RiderRegistrationService instance = RiderRegistrationService._();
  final List<RiderProfile> _profiles = <RiderProfile>[];
  late final List<RiderProfile> _profilesView = UnmodifiableListView(_profiles);
  RiderRepository? _remoteRepository;
  RiderProfile? _currentProfile;
  Rider? _currentRider;
  RiderVehicle? _currentVehicle;
  List<RiderDocument> _currentDocuments = const [];
  RiderLocation? _currentLocation;
  Future<RiderProfile?>? _loadRequest;

  RiderRepository get _repository =>
      _remoteRepository ??= RiderRepositoryImpl();
  List<RiderProfile> get registeredProfiles => _profilesView;
  RiderProfile? get currentProfile => _currentProfile;
  RiderVehicle? get currentVehicle => _currentVehicle;
  List<RiderDocument> get currentDocuments =>
      List.unmodifiable(_currentDocuments);
  RiderLocation? get currentLocation => _currentLocation;

  RiderProfile updateCurrentProfile(RiderProfile profile) {
    final index = _profiles.indexWhere((item) => item.email == profile.email);
    if (index < 0) {
      throw const RiderRegistrationException('Rider profile is unavailable.');
    }
    _profiles[index] = profile;
    _currentProfile = profile;
    notifyListeners();
    return profile;
  }

  Future<RiderProfile> saveCurrentProfile(RiderProfile profile) =>
      _saveCurrentProfile(profile);

  void selectProfile(String emailAddress) {
    final email = emailAddress.trim().toLowerCase();
    _currentProfile = _profiles
        .where((item) => item.email == email)
        .firstOrNull;
  }

  Future<RiderProfile?> loadCurrentProfile({bool force = false}) {
    if (!AgrisellSupabase.isInitialized) {
      return Future.value(_currentProfile);
    }
    if (!force && _currentProfile != null) return Future.value(_currentProfile);
    return _loadRequest ??= _loadRemoteProfile(
      force: force,
    ).whenComplete(() => _loadRequest = null);
  }

  Future<RiderProfile> register(
    RiderRegistration registration, {
    Map<RiderDraftDocumentType, RiderDraftDocument> documents = const {},
    RiderSignUpUploadProgress? onUploadProgress,
    bool emailAlreadyVerified = false,
  }) async {
    final validationMessage = RiderRegistrationValidator.validate(
      registration,
      requirePassword: !emailAlreadyVerified,
    );
    if (validationMessage != null) {
      throw RiderRegistrationException(validationMessage);
    }
    return AgrisellSupabase.isInitialized
        ? _registerRemote(registration, documents, onUploadProgress)
        : _registerLocal(registration);
  }

  Future<RiderProfile> _registerLocal(RiderRegistration registration) async {
    final email = registration.email.trim().toLowerCase();
    if (_profiles.any((profile) => profile.email == email)) {
      throw const RiderRegistrationException(
        'A rider account with this email already exists.',
      );
    }
    final account = await AuthRegistrationService.instance.registerRider(
      SignUpAccountData(
        firstName: registration.firstName.trim(),
        middleName: registration.middleName.trim(),
        lastName: registration.lastName.trim(),
        email: email,
        password: registration.password,
        phoneNumber: registration.contactNumber,
        dateOfBirth: registration.dateOfBirth,
        gender: registration.gender,
      ),
      RiderRegistrationPayload.fromRegistration(registration),
    );
    await AuthSessionService.instance.start(account, rememberMe: false);
    final profile = RiderProfile.fromRegistration(registration, id: account.id);
    _profiles.add(profile);
    _currentProfile = profile;
    notifyListeners();
    return profile;
  }

  void updateCurrentVerificationStatus(RiderVerificationStatus status) {
    final profile = _currentProfile;
    if (profile == null) return;
    _replaceCachedProfile(profile.withVerificationStatus(status));
  }

  void updateCurrentAvailability(RiderAvailability availability) {
    final profile = _currentProfile;
    if (profile == null || profile.availabilityStatus == availability) return;
    _replaceCachedProfile(profile.copyWith(availabilityStatus: availability));
  }

  void _replaceCachedProfile(RiderProfile profile) {
    final index = _profiles.indexWhere((item) => item.email == profile.email);
    if (index >= 0) _profiles[index] = profile;
    _currentProfile = profile;
    notifyListeners();
  }

  void _notifyChanged() => notifyListeners();
  void clearForTesting() {
    _profiles.clear();
    _clearCachedEntities();
  }

  void clearCurrentProfile() => _clearCachedEntities();
  void _clearCachedEntities() {
    _currentProfile = null;
    _currentRider = null;
    _currentVehicle = null;
    _currentDocuments = const [];
    _currentLocation = null;
    notifyListeners();
  }
}
