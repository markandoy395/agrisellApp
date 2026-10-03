import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

class FarmerInformationRequestFormController {
  FarmerInformationRequestFormController(FarmerVerificationDetails details)
    : firstName = TextEditingController(text: details.firstName ?? ''),
      lastName = TextEditingController(text: details.lastName ?? ''),
      phone = TextEditingController(text: details.phoneNumber ?? ''),
      farmName = TextEditingController(text: details.farmName ?? ''),
      farmAddress = TextEditingController(text: details.farmAddress ?? ''),
      notes = TextEditingController();

  final TextEditingController firstName;
  final TextEditingController lastName;
  final TextEditingController phone;
  final TextEditingController farmName;
  final TextEditingController farmAddress;
  final TextEditingController notes;

  void dispose() {
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    farmName.dispose();
    farmAddress.dispose();
    notes.dispose();
  }
}
