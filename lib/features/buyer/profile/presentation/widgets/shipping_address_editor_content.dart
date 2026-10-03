import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/profile/presentation/widgets/shipping_address_form.dart';

class ShippingAddressEditorContent extends StatelessWidget {
  const ShippingAddressEditorContent({
    required this.streetController,
    required this.fullName,
    required this.phoneNumber,
    required this.provinceController,
    required this.cityController,
    required this.barangayController,
    required this.postalCodeController,
    required this.isSaving,
    required this.error,
    required this.onAddressChanged,
    required this.onSave,
    super.key,
  });

  final TextEditingController streetController;
  final String fullName;
  final String phoneNumber;
  final TextEditingController provinceController;
  final TextEditingController cityController;
  final TextEditingController barangayController;
  final TextEditingController postalCodeController;
  final bool isSaving;
  final String? error;
  final VoidCallback onAddressChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shipping address',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your address. We will capture your delivery GPS location when you save.',
            style: SharedPresentationStyles.caption,
          ),
          const SizedBox(height: 14),
          ShippingAddressForm(
            streetController: streetController,
            fullName: fullName,
            phoneNumber: phoneNumber,
            provinceController: provinceController,
            cityController: cityController,
            barangayController: barangayController,
            postalCodeController: postalCodeController,
            isGeocoding: false,
            isSaving: isSaving,
            error: error,
            onAddressChanged: onAddressChanged,
            onSave: onSave,
          ),
        ],
      ),
    ),
  );
}
