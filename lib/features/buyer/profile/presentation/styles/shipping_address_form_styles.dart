import 'package:flutter/material.dart';

abstract final class ShippingAddressFormStyles {
  static const inputDecoration = InputDecoration(
    labelText: 'House number, street, or sitio/purok',
    hintText: 'e.g. House 12, Purok 5, near the chapel',
    helperText: 'Enter your province, city, and barangay below.',
    helperMaxLines: 2,
    border: OutlineInputBorder(),
  );

  static const inputDecoration2 = InputDecoration(
    labelText: 'Postal code (optional)',
    border: OutlineInputBorder(),
  );

  static InputDecoration inputDecoration3(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());
}
