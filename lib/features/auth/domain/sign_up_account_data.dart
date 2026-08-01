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
}

class RegisteredAccount {
  const RegisteredAccount({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.passwordHash,
    required this.passwordSalt,
    required this.role,
    required this.accountStatus,
    this.extensionName,
    this.phoneNumber,
    this.dateOfBirth,
    this.verificationStatus,
    this.shippingAddress,
    this.shippingLatitude,
    this.shippingLongitude,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String role;
  final String accountStatus;
  final String? extensionName;
  final String? phoneNumber;
  final String? dateOfBirth;
  final String? verificationStatus;
  final String? shippingAddress;
  final double? shippingLatitude;
  final double? shippingLongitude;

  AuthRole? get assignedRole => AuthRole.fromValue(role);

  AuthAccountStatus get status => AuthAccountStatus.fromValue(accountStatus);

  bool get isActive => status == AuthAccountStatus.active;

  bool get isFarmerVerificationPending =>
      assignedRole == AuthRole.farmer &&
      verificationStatus?.trim().toLowerCase() == 'pending';

  bool get isFarmerVerified =>
      assignedRole == AuthRole.farmer &&
      verificationStatus?.trim().toLowerCase() == 'verified';

  bool get requiresRiderApplicationStatus =>
      assignedRole == AuthRole.rider &&
      status == AuthAccountStatus.pending &&
      verificationStatus == 'pending';

  RegisteredAccount copyWith({
    String? passwordHash,
    String? passwordSalt,
    String? accountStatus,
    String? verificationStatus,
    String? extensionName,
    String? phoneNumber,
    String? dateOfBirth,
    String? shippingAddress,
    double? shippingLatitude,
    double? shippingLongitude,
  }) {
    return RegisteredAccount(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      role: role,
      accountStatus: accountStatus ?? this.accountStatus,
      extensionName: extensionName ?? this.extensionName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingLatitude: shippingLatitude ?? this.shippingLatitude,
      shippingLongitude: shippingLongitude ?? this.shippingLongitude,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  Map<String, Object> toJson() {
    return {
      'firstName': firstName,
      'id': id,
      'lastName': lastName,
      'email': email,
      'role': role,
      'accountStatus': accountStatus,
      ...switch (extensionName) {
        final value? => {'extensionName': value},
        null => const <String, Object>{},
      },
      ...switch (phoneNumber) {
        final value? => {'phoneNumber': value},
        null => const <String, Object>{},
      },
      ...switch (dateOfBirth) {
        final value? => {'dateOfBirth': value},
        null => const <String, Object>{},
      },
      ...switch (verificationStatus) {
        final status? => {'verificationStatus': status},
        null => const <String, Object>{},
      },
      ...switch (shippingAddress) {
        final value? => {'shippingAddress': value},
        null => const <String, Object>{},
      },
    };
  }
}
