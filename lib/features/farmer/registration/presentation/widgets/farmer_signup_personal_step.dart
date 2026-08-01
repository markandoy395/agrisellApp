import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_gender_choice.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

class FarmerSignupPersonalStep extends StatelessWidget {
  const FarmerSignupPersonalStep({
    required this.controllers,
    required this.errors,
    required this.onChanged,
    required this.onPickDate,
    required this.onPickImage,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final Map<String, String?> errors;
  final VoidCallback onChanged;
  final VoidCallback onPickDate;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Personal information',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      FarmerSignupField(
        label: 'First name',
        controller: controllers.firstName,
        error: errors['firstName'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Middle name (optional)',
        controller: controllers.middleName,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Last name',
        controller: controllers.lastName,
        error: errors['lastName'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Suffix (optional)',
        controller: controllers.suffix,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Phone number (09XXXXXXXXX)',
        controller: controllers.phone,
        keyboardType: TextInputType.phone,
        inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
        error: errors['phone'],
        onChanged: (_) => onChanged(),
      ),
      PhoneNumberSyncControl(
        controller: controllers.phone,
        onSynced: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Date of birth',
        controller: controllers.dateOfBirth,
        readOnly: true,
        onTap: onPickDate,
        error: errors['dateOfBirth'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupGenderChoice(
        controller: controllers.gender,
        onChanged: onChanged,
      ),
      FarmerSignupField(
        label: 'Street / address line (manual entry)',
        controller: controllers.address,
        onChanged: (_) => onChanged(),
      ),
      PsgcAddressFields(
        provinceController: controllers.province,
        cityController: controllers.city,
        barangayController: controllers.barangay,
        onChanged: onChanged,
      ),
      FarmerSignupField(
        label: 'Postal code',
        controller: controllers.postalCode,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged(),
      ),
      FarmerImagePickerButton(
        label: 'Add profile image (optional)',
        hasImage: controllers.profileImage != null,
        onPressed: onPickImage,
      ),
    ],
  );
}
