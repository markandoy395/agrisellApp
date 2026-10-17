import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';

UserProfile currentAuthenticatedUserProfile() {
  final account = AuthSessionService.instance.currentAccount;
  if (account == null) {
    return const UserProfile(
      name: 'Account',
      email: '',
      address: '',
      phoneNumber: '',
      gender: '',
      dateOfBirth: '',
      firstName: '',
      lastName: '',
      extensionName: '',
    );
  }

  final fullName = [
    account.firstName,
    account.lastName,
    account.extensionName ?? '',
  ].where((part) => part.trim().isNotEmpty).join(' ');
  return UserProfile(
    name: fullName.isEmpty ? 'Account' : fullName,
    email: account.email,
    address: account.shippingAddress ?? '',
    phoneNumber: PhilippinePhoneNumber.display(account.phoneNumber ?? ''),
    gender: account.gender,
    dateOfBirth: ProfileBirthDate.parse(account.dateOfBirth ?? '').formatted,
    firstName: account.firstName,
    lastName: account.lastName,
    extensionName: account.extensionName ?? '',
    shippingLatitude: account.shippingLatitude,
    shippingLongitude: account.shippingLongitude,
    avatarUrl: account.profileImageUrl,
  );
}
