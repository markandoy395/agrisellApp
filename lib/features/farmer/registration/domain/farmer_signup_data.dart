import 'dart:typed_data';

class FarmerSignupData {
  const FarmerSignupData({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.farmName,
    required this.mainCrops,
    this.middleName,
    this.suffix,
    this.dateOfBirth,
    this.gender,
    this.addressLine,
    this.barangay,
    this.cityMunicipality,
    this.province,
    this.postalCode,
    this.farmLocation,
    this.farmBarangay,
    this.farmCityMunicipality,
    this.farmProvince,
    this.latitude,
    this.longitude,
    this.yearsOfExperience,
    this.farmSize,
    this.farmSizeUnit,
    this.farmingType,
    this.irrigationType,
    this.ownershipType,
    this.profileImage,
    this.farmImage,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String farmName;
  final List<String> mainCrops;
  final String? middleName;
  final String? suffix;
  final String? dateOfBirth;
  final String? gender;
  final String? addressLine;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final String? postalCode;
  final String? farmLocation;
  final String? farmBarangay;
  final String? farmCityMunicipality;
  final String? farmProvince;
  final double? latitude;
  final double? longitude;
  final int? yearsOfExperience;
  final double? farmSize;
  final String? farmSizeUnit;
  final String? farmingType;
  final String? irrigationType;
  final String? ownershipType;
  final Uint8List? profileImage;
  final Uint8List? farmImage;

  Map<String, Object?> toAuthMetadata() {
    final crops = mainCrops.where((crop) => crop.trim().isNotEmpty).toList();
    return {
      'requested_role': 'farmer',
      'first_name': firstName.trim(),
      'middle_name': _blankToNull(middleName),
      'last_name': lastName.trim(),
      'suffix': _blankToNull(suffix),
      'phone_number': phoneNumber.trim(),
      'date_of_birth': _blankToNull(dateOfBirth),
      'gender': _blankToNull(gender),
      'address_line': _blankToNull(addressLine),
      'barangay': _blankToNull(barangay),
      'city_municipality': _blankToNull(cityMunicipality),
      'province': _blankToNull(province),
      'postal_code': _blankToNull(postalCode),
      'farm_name': farmName.trim(),
      'farm_location': _blankToNull(farmLocation),
      'farm_barangay': _blankToNull(farmBarangay),
      'farm_city_municipality': _blankToNull(farmCityMunicipality),
      'farm_province': _blankToNull(farmProvince),
      'latitude': latitude,
      'longitude': longitude,
      'years_of_experience': yearsOfExperience,
      'farm_size': farmSize,
      'farm_size_unit': _blankToNull(farmSizeUnit),
      'farming_type': _blankToNull(farmingType),
      'irrigation_type': _blankToNull(irrigationType),
      'ownership_type': _blankToNull(ownershipType),
      'main_crops': crops,
      'total_crops': crops.length,
    };
  }
}

String? _blankToNull(String? value) {
  final text = value?.trim() ?? '';
  return text.isEmpty ? null : text;
}
