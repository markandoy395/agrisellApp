import 'package:flutter/material.dart';

abstract final class RiderDeliveryConfirmationFormStyles {
  static const inputDecoration = InputDecoration(
    labelText: 'Delivery confirmation code',
    helperText: 'The code is validated securely and is never logged.',
  );

  static const inputDecoration2 = InputDecoration(labelText: 'QR code value');

  static const inputDecoration3 = InputDecoration(labelText: 'Delivery notes');
}
