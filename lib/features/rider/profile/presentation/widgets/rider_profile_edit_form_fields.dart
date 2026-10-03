import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_form_fields_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_styles.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

class RiderProfileEditFormFields extends StatelessWidget {
  const RiderProfileEditFormFields({
    required this.profile,
    required this.firstNameController,
    required this.lastNameController,
    required this.contactController,
    required this.streetController,
    required this.provinceController,
    required this.cityController,
    required this.barangayController,
    required this.postalController,
    required this.licenseController,
    required this.plateController,
    required this.error,
    required this.onPsgcChanged,
    super.key,
  });

  final RiderProfile profile;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController contactController;
  final TextEditingController streetController;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController barangayController;
  final TextEditingController postalController;
  final TextEditingController licenseController;
  final TextEditingController plateController;
  final String? error;
  final VoidCallback onPsgcChanged;

  Widget _field(
    String label,
    TextEditingController controller,
    TextInputType type,
  ) => Padding(
    padding: RiderProfileEditStyles.fieldBottomPadding,
    child: TextField(
      controller: controller,
      keyboardType: type,
      decoration: RiderProfileEditFormFieldsStyles.inputDecoration(label),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _field('First name', firstNameController, TextInputType.name),
        _field('Last name', lastNameController, TextInputType.name),
        _field('Contact number', contactController, TextInputType.phone),
        PhoneNumberSyncControl(controller: contactController),
        RiderProfileEditStyles.spacingMedium,
        const Text(
          'Official address',
          style: RiderProfileEditStyles.sectionHeaderStyle,
        ),
        _field(
          'House, building, street, or sitio',
          streetController,
          TextInputType.streetAddress,
        ),
        PsgcAddressFields(
          provinceController: provinceController,
          cityController: cityController,
          barangayController: barangayController,
          onChanged: onPsgcChanged,
        ),
        _field(
          'Postal code (optional)',
          postalController,
          TextInputType.number,
        ),
        if (profile.vehicleType.requiresLicense)
          _field('License number', licenseController, TextInputType.text),
        if (profile.vehicleType.requiresPlate)
          _field('Vehicle plate number', plateController, TextInputType.text),
        if (error != null)
          Padding(
            padding: RiderProfileEditStyles.errorPadding,
            child: Text(error!, style: RiderProfileEditStyles.errorTextStyle),
          ),
      ],
    );
  }
}
