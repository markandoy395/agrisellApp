import 'package:flutter/material.dart';

abstract final class ShippingAddressFormStyles {
  static const inputDecoration = InputDecoration(
    labelText: 'Complete address',
    border: OutlineInputBorder(),
  );

  static const inputDecoration2 = InputDecoration(
    labelText: 'Postal code (optional)',
    border: OutlineInputBorder(),
  );

  static InputDecoration inputDecoration3(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());
}
