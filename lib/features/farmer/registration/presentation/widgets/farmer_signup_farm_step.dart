import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_address_sync_control.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_options_field.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/location_map_preview.dart';

class FarmerSignupFarmStep extends StatelessWidget {
  const FarmerSignupFarmStep({
    required this.controllers,
    required this.errors,
    required this.onChanged,
    required this.onPickLocation,
    required this.onPickImage,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final Map<String, String?> errors;
  final VoidCallback onChanged;
  final VoidCallback onPickLocation;
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
      FarmerSignupField(
        label: 'Farm street / address line',
        controller: controllers.farmAddress,
        error: errors['farmAddress'],
        onChanged: (_) => onChanged(),
      ),
      LocationMapPreview(
        latitude: double.tryParse(controllers.latitude.text),
        longitude: double.tryParse(controllers.longitude.text),
        onTap: onPickLocation,
        emptyLabel: 'Tap to select the exact farm location *',
        selectedLabel: 'Tap to adjust the farm location pin',
      ),
      const SizedBox(height: 8),
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
      PsgcAddressFields(
        provinceController: controllers.farmProvince,
        cityController: controllers.farmCity,
        barangayController: controllers.farmBarangay,
        onChanged: onChanged,
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
        error: errors['farmSize'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Farm size unit',
        controller: controllers.farmSizeUnit,
        error: errors['farmSizeUnit'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupOptionsField(
        label: 'Farming type',
        controller: controllers.farmingType,
        error: errors['farmingType'],
        options: const [
          'Conventional farming',
          'Organic farming',
          'Mixed crop and livestock farming',
          'Hydroponic farming',
          'Aquaponic farming',
          'Livestock farming',
          'Poultry farming',
          'Agroforestry',
        ],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Main crops (comma-separated)',
        controller: controllers.mainCrops,
        error: errors['mainCrops'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Irrigation type (optional)',
        controller: controllers.irrigationType,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Farm ownership type (optional)',
        controller: controllers.ownershipType,
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
