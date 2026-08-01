import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';

class RiderSignUpAvailabilityService {
  Future<bool> isEmailAvailable(String value) async {
    final email = value.trim().toLowerCase();
    return !AuthRegistrationService.instance.registeredAccounts.any(
      (account) => account.email == email,
    );
  }

  Future<bool> isMobileAvailable(String value) async {
    final mobile = _normalized(value);
    return !RiderRegistrationService.instance.registeredProfiles.any(
      (profile) => _normalized(profile.contactNumber) == mobile,
    );
  }

  String _normalized(String value) => value.replaceAll(RegExp(r'[ -]'), '');
}
