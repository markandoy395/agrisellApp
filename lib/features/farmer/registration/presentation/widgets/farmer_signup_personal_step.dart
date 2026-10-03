import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_personal_step_styles.dart';
import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

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
      Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: FarmerSignupPersonalStepStyles.containerDecoration,
            child: const Icon(Icons.person_outline, color: Color(0xFF075239)),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal information',
                  style: FarmerSignupPersonalStepStyles.personalInformationText,
                ),
                Text(
                  'Tell us more about yourself.',
                  style: FarmerSignupPersonalStepStyles
                      .tellUsMoreAboutYourselfText,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      FarmerSignupField(
        label: 'First name',
        controller: controllers.firstName,
        leadingIcon: Icons.person_outline,
        leadingIconDivider: false,
        error: errors['firstName'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Middle name (optional)',
        controller: controllers.middleName,
        leadingIcon: Icons.person_outline,
        leadingIconDivider: false,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Last name',
        controller: controllers.lastName,
        leadingIcon: Icons.person_outline,
        leadingIconDivider: false,
        error: errors['lastName'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Suffix (optional)',
        controller: controllers.suffix,
        leadingIcon: Icons.description_outlined,
        leadingIconDivider: false,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Phone number (09XXXXXXXXX)',
        controller: controllers.phone,
        leadingIcon: Icons.phone_outlined,
        leadingIconDivider: false,
        keyboardType: TextInputType.phone,
        inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
        error: errors['phone'],
        onChanged: (_) => onChanged(),
      ),
      PhoneNumberSyncControl(
        controller: controllers.phone,
        onSynced: (_) => onChanged(),
        spacious: true,
        cardStyle: true,
      ),
      const SizedBox(height: 12),
      FarmerSignupField(
        label: 'Date of birth',
        controller: controllers.dateOfBirth,
        leadingIcon: Icons.calendar_month_outlined,
        leadingIconDivider: false,
        trailingIcon: Icons.calendar_month_outlined,
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
        leadingIcon: Icons.location_on_outlined,
        leadingIconDivider: false,
        onChanged: (_) => onChanged(),
      ),
      PsgcAddressFields(
        provinceController: controllers.province,
        cityController: controllers.city,
        barangayController: controllers.barangay,
        onChanged: onChanged,
        showSignupIcons: true,
        leadingIconBuilder: AuthInputStyle.iconBadge,
        decorationTheme: AuthInputStyle.dropdownTheme,
      ),
      FarmerSignupField(
        label: 'Postal code',
        controller: controllers.postalCode,
        leadingIcon: Icons.mail_outline,
        leadingIconDivider: false,
        keyboardType: TextInputType.number,
        onChanged: (_) => onChanged(),
      ),
      FarmerImagePickerButton(
        label: 'Add profile image (optional)',
        hasImage: controllers.profileImage != null,
        onPressed: onPickImage,
        profileStyle: true,
      ),
    ],
  );
}
