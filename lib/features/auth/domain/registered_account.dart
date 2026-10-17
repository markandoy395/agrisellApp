part of 'sign_up_account_data.dart';

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
    this.profileImageUrl,
    this.profilePending = false,
    this.gender = '',
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
  final String? profileImageUrl;
  final bool profilePending;
  final String gender;

  AuthRole? get assignedRole => AuthRole.fromValue(role);

  AuthAccountStatus get status => AuthAccountStatus.fromValue(accountStatus);

  bool get isActive => status == AuthAccountStatus.active;

  bool get isFarmerVerificationPending =>
      assignedRole == AuthRole.farmer &&
      verificationStatus?.trim().toLowerCase() == 'pending';

  bool get canUploadProducts =>
      assignedRole == AuthRole.farmer &&
      isActive &&
      const [
        'pending',
        'verified',
        'needs_information',
      ].contains(verificationStatus?.trim().toLowerCase());

  bool get isFarmerVerified =>
      assignedRole == AuthRole.farmer &&
      verificationStatus?.trim().toLowerCase() == 'verified';

  bool get isBuyerVerified =>
      assignedRole == AuthRole.buyer &&
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
    String? profileImageUrl,
    bool? profilePending,
  }) {
    return RegisteredAccount(
      id: id,
      firstName: firstName,
      gender: gender,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      profilePending: profilePending ?? this.profilePending,
    );
  }

  Map<String, Object> toJson() {
    return {
      'firstName': firstName,
      'gender': gender,
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
      if (profilePending) 'profilePending': true,
    };
  }
}
