import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/features/farmer/registration/domain/farmer_registration_choices.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_address_sync_control.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_crops_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_select_field.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';

class FarmerSignupFarmStep extends StatelessWidget {
  const FarmerSignupFarmStep({
    required this.controllers,
    required this.errors,
    required this.onChanged,
    required this.onPickImage,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final Map<String, String?> errors;
  final VoidCallback onChanged;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Farm information',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      const Text(
        'At least one farm is required to sell on Agrisell.',
        style: TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 12),
      FarmerSignupField(
        label: 'Farm name',
        controller: controllers.farmName,
        error: errors['farmName'],
        onChanged: (_) => onChanged(),
      ),
      Opacity(
        opacity: controllers.sameAsFarmerAddress ? 0.55 : 1,
        child: FarmerSignupField(
          label: 'Farm street / address line',
          controller: controllers.farmAddress,
          enabled: !controllers.sameAsFarmerAddress,
          error: errors['farmAddress'],
          onChanged: (_) => onChanged(),
        ),
      ),
      if (errors['farmLocation'] != null)
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            errors['farmLocation']!,
            style: const TextStyle(
              color: AgrisellColors.statusRedText,
              fontSize: 12,
            ),
          ),
        ),
      FarmerAddressSyncControl(controllers: controllers, onSynced: onChanged),
      Opacity(
        opacity: controllers.sameAsFarmerAddress ? 0.55 : 1,
        child: PsgcAddressFields(
          provinceController: controllers.farmProvince,
          cityController: controllers.farmCity,
          barangayController: controllers.farmBarangay,
          enabled: !controllers.sameAsFarmerAddress,
          onChanged: onChanged,
          showSignupIcons: true,
          leadingIconBuilder: AuthInputStyle.iconBadge,
          decorationTheme: AuthInputStyle.dropdownTheme,
        ),
      ),
      if (errors['farmAddressDetails'] != null)
        _FarmStepError(message: errors['farmAddressDetails']!),
      FarmerSignupField(
        label: 'Years of farming experience',
        controller: controllers.yearsOfExperience,
        keyboardType: TextInputType.number,
        error: errors['yearsOfExperience'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Farm size',
        controller: controllers.farmSize,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          TextInputFormatter.withFunction(
            (oldValue, newValue) =>
                RegExp(r'^\d*(\.\d{0,3})?$').hasMatch(newValue.text)
                ? newValue
                : oldValue,
          ),
        ],
        error: errors['farmSize'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupSelectField(
        label: 'Farm Size Unit',
        controller: controllers.farmSizeUnit,
        options: FarmerRegistrationChoices.farmSizeUnits,
        optionLabels: const {
          'ha': 'Hectares (ha)',
          'sq m': 'Square Meters (sq m)',
        },
        error: errors['farmSizeUnit'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupSelectField(
        label: 'Farming Type',
        controller: controllers.farmingType,
        error: errors['farmingType'],
        options: FarmerRegistrationChoices.farmingTypes,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupSelectField(
        label: 'Land Tenure / Ownership Status',
        controller: controllers.ownershipType,
        error: errors['ownershipType'],
        options: FarmerRegistrationChoices.landTenures,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupCropsField(
        controller: controllers.mainCrops,
        error: errors['mainCrops'],
        onChanged: onChanged,
      ),
      FarmerSignupSelectField(
        label: 'Irrigation Type (optional)',
        controller: controllers.irrigationType,
        options: FarmerRegistrationChoices.irrigationTypes,
        error: errors['irrigationType'],
        onChanged: (_) => onChanged(),
      ),
      FarmerImagePickerButton(
        label: 'Add farm image (optional)',
        hasImage: controllers.farmImage != null,
        onPressed: onPickImage,
      ),
    ],
  );
}

class _FarmStepError extends StatelessWidget {
  const _FarmStepError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      message,
      style: const TextStyle(color: AgrisellColors.statusRedText, fontSize: 12),
    ),
  );
}
