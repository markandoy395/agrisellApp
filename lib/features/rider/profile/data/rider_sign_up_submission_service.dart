import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration_validator.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';

typedef RiderSignUpUploadProgress =
    void Function(RiderDraftDocumentType type, double progress);

class RiderSignUpSubmissionService {
  Future<RiderProfile> submit({
    required RiderSignUpDraft draft,
    required String licenseNumber,
    required String password,
    required String confirmPassword,
    bool emailAlreadyVerified = false,
    RiderSignUpUploadProgress? onUploadProgress,
  }) async {
    final registration = _registration(
      draft: draft,
      licenseNumber: licenseNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
    final validation = RiderRegistrationValidator.validate(
      registration,
      requirePassword: !emailAlreadyVerified,
    );
    if (validation != null) throw RiderRegistrationException(validation);
    return RiderRegistrationService.instance.register(
      registration,
      documents: draft.documents,
      onUploadProgress: onUploadProgress,
      emailAlreadyVerified: emailAlreadyVerified,
    );
  }

  RiderRegistration _registration({
    required RiderSignUpDraft draft,
    required String licenseNumber,
    required String password,
    required String confirmPassword,
  }) => RiderRegistration(
    firstName: draft.value(RiderSignUpFields.firstName),
    middleName: draft.value(RiderSignUpFields.middleName),
    lastName: draft.value(RiderSignUpFields.lastName),
    dateOfBirth: draft.value(RiderSignUpFields.dateOfBirth),
    gender: draft.value(RiderSignUpFields.gender),
    contactNumber: draft.value(RiderSignUpFields.mobile),
    email: draft.value(RiderSignUpFields.email),
    gpsLatitude: double.tryParse(draft.value(RiderSignUpFields.latitude)),
    gpsLongitude: double.tryParse(draft.value(RiderSignUpFields.longitude)),
    locationLabel: draft.value(RiderSignUpFields.location),
    addressLine: draft.value(RiderSignUpFields.addressLine),
    barangay: draft.value(RiderSignUpFields.barangay),
    cityMunicipality: draft.value(RiderSignUpFields.cityMunicipality),
    province: draft.value(RiderSignUpFields.province),
    postalCode: draft.value(RiderSignUpFields.postalCode),
    locationNotes: draft.value(RiderSignUpFields.locationNotes),
    gpsAccuracyMeters: double.tryParse(
      draft.value(RiderSignUpFields.locationAccuracy),
    ),
    locationCapturedAt: DateTime.tryParse(
      draft.value(RiderSignUpFields.locationCapturedAt),
    ),
    vehicleType: RiderVehicleType.values.firstWhere(
      (type) => type.name == draft.value(RiderSignUpFields.vehicleType),
    ),
    vehiclePlateNumber: draft.value(RiderSignUpFields.plate),
    licenseNumber: licenseNumber,
    profilePhotoPath:
        draft.documents[RiderDraftDocumentType.profilePhoto]?.path,
    password: password,
    confirmPassword: confirmPassword,
    acceptsTerms: draft.acceptsTerms,
    acceptsPrivacy: draft.acceptsPrivacy,
    confirmsAccuracy: draft.confirmsAccuracy,
    logisticsCompanyId: draft.value(RiderSignUpFields.logisticsCompanyId),
  );
}
