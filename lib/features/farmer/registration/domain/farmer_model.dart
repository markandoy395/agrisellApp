class FarmerModel {
  const FarmerModel({
    required this.id,
    required this.authUserId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.accountStatus,
    required this.verificationStatus,
    this.middleName,
    this.suffix,
    this.dateOfBirth,
    this.gender,
    this.addressLine,
    this.barangay,
    this.cityMunicipality,
    this.province,
    this.postalCode,
    this.profileImageUrl,
  });

  final int id;
  final String authUserId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String accountStatus;
  final String verificationStatus;
  final String? middleName;
  final String? suffix;
  final String? dateOfBirth;
  final String? gender;
  final String? addressLine;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final String? postalCode;
  final String? profileImageUrl;

  factory FarmerModel.fromJson(Map<String, dynamic> json) => FarmerModel(
    id: json['farmer_user_id'] as int,
    authUserId: json['auth_user_id'] as String,
    firstName: _text(json['first_name']),
    lastName: _text(json['last_name']),
    phoneNumber: _text(json['phone_number']),
    accountStatus: _text(json['account_status'], fallback: 'active'),
    verificationStatus: _text(json['verification_status'], fallback: 'pending'),
    middleName: _optionalText(json['middle_name']),
    suffix: _optionalText(json['suffix']),
    dateOfBirth: _optionalText(json['date_of_birth']),
    gender: _optionalText(json['gender']),
    addressLine: _optionalText(json['address_line']),
    barangay: _optionalText(json['barangay']),
    cityMunicipality: _optionalText(json['city_municipality']),
    province: _optionalText(json['province']),
    postalCode: _optionalText(json['postal_code']),
    profileImageUrl: _optionalText(json['profile_image_url']),
  );
}

String _text(Object? value, {String fallback = ''}) =>
    _optionalText(value) ?? fallback;

String? _optionalText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
