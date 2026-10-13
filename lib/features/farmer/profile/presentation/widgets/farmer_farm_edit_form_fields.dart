import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';

import 'package:agresell_app/features/farmer/profile/presentation/controllers/farmer_farm_form_controllers.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import '../styles/farmer_farm_edit_styles.dart';
import 'farmer_farm_form_style.dart';

class FarmerFarmEditFormFields extends StatelessWidget {
  const FarmerFarmEditFormFields({
    required this.controllers,
    required this.onAddressChanged,
    super.key,
  });

  final FarmerFarmFormControllers controllers;
  final VoidCallback onAddressChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FarmerFarmField(
          label: 'Farm Name',
          icon: Icons.spa_rounded,
          controller: controllers.name,
        ),
        FarmerFarmField(
          label: 'Farm Address',
          icon: Icons.home_rounded,
          controller: controllers.location,
        ),
        PsgcAddressFields(
          provinceController: controllers.province,
          cityController: controllers.city,
          barangayController: controllers.barangay,
          onChanged: onAddressChanged,
          showSignupIcons: true,
          leadingIconBuilder: AuthInputStyle.iconBadge,
          decorationTheme: AuthInputStyle.dropdownTheme,
        ),
        FarmerFarmEditStyles.spacingFields,
        FarmerFarmField(
          label: 'Size (hectares)',
          icon: Icons.view_week_rounded,
          controller: controllers.size,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        FarmerFarmField(
          label: 'Farming Type',
          icon: Icons.eco_rounded,
          controller: controllers.farmingType,
        ),
        FarmerFarmField(
          label: 'Irrigation Type',
          icon: Icons.water_drop_outlined,
          controller: controllers.irrigation,
          required: false,
        ),
        FarmerFarmField(
          label: 'Main Crops',
          icon: Icons.grass_rounded,
          controller: controllers.crops,
        ),
      ],
    );
  }
}
