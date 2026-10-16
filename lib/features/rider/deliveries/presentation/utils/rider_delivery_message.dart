import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

void showRiderDeliveryMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showAppSnackBar(
    SnackBar(content: Text(message)),
    duration: const Duration(seconds: 6),
  );
}
