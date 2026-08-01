import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/psgc_address_fields.dart';

class ShippingAddressForm extends StatelessWidget {
  const ShippingAddressForm({
    required this.streetController,
    required this.fullName,
    required this.phoneNumber,
    required this.provinceController,
    required this.cityController,
    required this.barangayController,
    required this.postalCodeController,
    required this.isGeocoding,
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
  final bool isGeocoding;
  final bool isSaving;
  final String? error;
  final VoidCallback onAddressChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (fullName.isNotEmpty) ...[
        _RecipientField(label: 'Full name', value: fullName),
        const SizedBox(height: 10),
      ],
      if (phoneNumber.isNotEmpty) ...[
        _RecipientField(label: 'Phone number', value: phoneNumber),
        const SizedBox(height: 10),
      ],
      TextField(
        controller: streetController,
        keyboardType: TextInputType.streetAddress,
        decoration: const InputDecoration(
          labelText: 'Complete address',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 10),
      PsgcAddressFields(
        provinceController: provinceController,
        cityController: cityController,
        barangayController: barangayController,
        onChanged: onAddressChanged,
      ),
      const SizedBox(height: 10),
      TextField(
        controller: postalCodeController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Postal code (optional)',
          border: OutlineInputBorder(),
        ),
      ),
      if (isGeocoding)
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Locating address...', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      if (error != null) ...[
        const SizedBox(height: 8),
        Text(
          error!,
          style: const TextStyle(
            fontSize: 12,
            color: AgrisellColors.statusRedText,
          ),
        ),
      ],
      const SizedBox(height: 14),
      SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton(
          onPressed: isSaving ? null : onSave,
          child: Text(isSaving ? 'Saving...' : 'Save address'),
        ),
      ),
    ],
  );
}

class _RecipientField extends StatelessWidget {
  const _RecipientField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: Text(value, style: const TextStyle(fontSize: 13)),
  );
}
