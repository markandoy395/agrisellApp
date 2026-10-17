import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';

class SignUpFormControllers {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final extensionName = TextEditingController();
  final contactNumber = TextEditingController();
  final dateOfBirth = TextEditingController();
  final gender = TextEditingController();
  final shippingAddress = TextEditingController();
  final shippingProvince = TextEditingController();
  final shippingCity = TextEditingController();
  final shippingBarangay = TextEditingController();
  final shippingPostalCode = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    extensionName.dispose();
    contactNumber.dispose();
    dateOfBirth.dispose();
    gender.dispose();
    shippingAddress.dispose();
    shippingProvince.dispose();
    shippingCity.dispose();
    shippingBarangay.dispose();
    shippingPostalCode.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
  }

  SignUpAccountData toAccountData({bool acceptedPolicy = false}) =>
      SignUpAccountData(
        acceptedPolicy: acceptedPolicy,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        extensionName: extensionName.text.trim(),
        phoneNumber: PhilippinePhoneNumber.normalize(contactNumber.text),
        dateOfBirth: dateOfBirth.text.trim(),
        gender: gender.text.trim(),
        shippingAddress: completeShippingAddress,
        email: email.text.trim().toLowerCase(),
        password: password.text,
      );

  String get completeShippingAddress {
    final requiredParts = [
      shippingAddress,
      shippingProvince,
      shippingCity,
      shippingBarangay,
    ];
    if (requiredParts.any((controller) => controller.text.trim().isEmpty)) {
      return '';
    }
    return [
      shippingAddress.text.trim(),
      'Barangay ${shippingBarangay.text.trim()}',
      shippingCity.text.trim(),
      shippingProvince.text.trim(),
      shippingPostalCode.text.trim(),
      'Philippines',
    ].where((part) => part.isNotEmpty).join(', ');
  }
}
