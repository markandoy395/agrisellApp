import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_signup_data.dart';
import 'package:agresell_app/features/farmer/registration/domain/philippine_crops.dart';

class FarmerSignupControllers {
  FarmerSignupControllers() {
    for (final controller in [address, province, city, barangay]) {
      controller.addListener(_syncFarmAddress);
    }
  }

  bool sameAsFarmerAddress = false;
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final firstName = TextEditingController();
  final middleName = TextEditingController();
  final lastName = TextEditingController();
  final suffix = TextEditingController();
  final phone = TextEditingController();
  final dateOfBirth = TextEditingController();
  final gender = TextEditingController();
  final address = TextEditingController();
  final barangay = TextEditingController();
  final city = TextEditingController();
  final province = TextEditingController();
  final postalCode = TextEditingController();
  final farmName = TextEditingController();
  final farmAddress = TextEditingController();
  final farmBarangay = TextEditingController();
  final farmCity = TextEditingController();
  final farmProvince = TextEditingController();
  final latitude = TextEditingController();
  final longitude = TextEditingController();
  final yearsOfExperience = TextEditingController();
  final farmSize = TextEditingController();
  final farmSizeUnit = TextEditingController(text: 'ha');
  final farmingType = TextEditingController();
  final mainCrops = TextEditingController();
  final irrigationType = TextEditingController();
  final ownershipType = TextEditingController();
  Uint8List? profileImage;
  Uint8List? farmImage;

  Iterable<TextEditingController> get all => [
    email,
    password,
    confirmPassword,
    firstName,
    middleName,
    lastName,
    suffix,
    phone,
    dateOfBirth,
    gender,
    address,
    barangay,
    city,
    province,
    postalCode,
    farmName,
    farmAddress,
    farmBarangay,
    farmCity,
    farmProvince,
    latitude,
    longitude,
    yearsOfExperience,
    farmSize,
    farmSizeUnit,
    farmingType,
    mainCrops,
    irrigationType,
    ownershipType,
  ];

  bool get isDirty =>
      all.any((controller) => controller.text.trim().isNotEmpty);

  FarmerSignupData data() => FarmerSignupData(
    email: email.text,
    password: password.text,
    firstName: firstName.text,
    lastName: lastName.text,
    phoneNumber: PhilippinePhoneNumber.normalize(phone.text) ?? phone.text,
    farmName: farmName.text,
    mainCrops: PhilippineCrops.parseSelection(mainCrops.text),
    middleName: middleName.text,
    suffix: suffix.text,
    dateOfBirth: dateOfBirth.text,
    gender: gender.text,
    addressLine: address.text,
    barangay: barangay.text,
    cityMunicipality: city.text,
    province: province.text,
    postalCode: postalCode.text,
    farmLocation: farmAddress.text,
    farmBarangay: farmBarangay.text,
    farmCityMunicipality: farmCity.text,
    farmProvince: farmProvince.text,
    latitude: double.tryParse(latitude.text),
    longitude: double.tryParse(longitude.text),
    yearsOfExperience: int.tryParse(yearsOfExperience.text),
    farmSize: double.tryParse(farmSize.text),
    farmSizeUnit: farmSizeUnit.text,
    farmingType: farmingType.text,
    irrigationType: irrigationType.text,
    ownershipType: ownershipType.text,
    profileImage: profileImage,
    farmImage: farmImage,
  );

  void setFarmCoordinates({
    required double latitudeValue,
    required double longitudeValue,
  }) {
    latitude.text = latitudeValue.toString();
    longitude.text = longitudeValue.toString();
  }

  bool get hasPersonalAddressDetails => [
    address,
    province,
    city,
    barangay,
  ].every((controller) => controller.text.trim().isNotEmpty);

  void setSameAsFarmerAddress(bool value) {
    sameAsFarmerAddress = value;
    if (value) copyPersonalAddressDetailsToFarm();
  }

  void _syncFarmAddress() {
    if (sameAsFarmerAddress) copyPersonalAddressDetailsToFarm();
  }

  void copyPersonalAddressDetailsToFarm() {
    final pairs = [
      (farmAddress, address),
      (farmProvince, province),
      (farmCity, city),
      (farmBarangay, barangay),
    ];
    for (final (target, source) in pairs) {
      final value = source.text.trim();
      if (target.text != value) target.text = value;
    }
  }

  void dispose() {
    for (final controller in [address, province, city, barangay]) {
      controller.removeListener(_syncFarmAddress);
    }
    for (final controller in all) {
      controller.dispose();
    }
  }
}
