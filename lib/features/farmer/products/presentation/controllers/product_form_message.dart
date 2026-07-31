import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

void showProductFormMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showAppSnackBar(SnackBar(content: Text(message)));
}
