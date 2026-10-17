part 'registered_account.dart';

enum AuthRole {
  farmer('farmer', 'Farmer'),
  buyer('buyer', 'Buyer'),
  rider('rider', 'Rider');

  const AuthRole(this.value, this.label);

  final String value;
  final String label;

  static AuthRole? fromValue(String value) {
    for (final role in AuthRole.values) {
      if (role.value == value) return role;
    }
    return null;
  }
}

enum AuthAccountStatus {
  active('active'),
  pending('pending'),
  suspended('suspended'),
  rejected('rejected'),
  disabled('disabled'),
  unknown('unknown');

  const AuthAccountStatus(this.value);

  final String value;

  static AuthAccountStatus fromValue(String value) {
    for (final status in AuthAccountStatus.values) {
      if (status.value == value) return status;
    }
    return AuthAccountStatus.unknown;
  }
}

class SignUpAccountData {
  const SignUpAccountData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.extensionName,
    this.middleName,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.shippingAddress,
    this.acceptedPolicy = false,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? extensionName;
  final String? middleName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? gender;
  final String? shippingAddress;
  final bool acceptedPolicy;
}
