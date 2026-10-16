import 'package:flutter/material.dart';

abstract final class FarmerDeliveryFeeStyles {
  static const input = InputDecoration(
    labelText: 'Delivery fee (PHP)',
    helperText: 'Separate from payment for the products.',
    border: OutlineInputBorder(),
  );
  static const padding = EdgeInsets.symmetric(vertical: 12);
}
