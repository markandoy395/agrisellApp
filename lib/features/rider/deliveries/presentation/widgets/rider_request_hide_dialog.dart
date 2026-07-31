import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_action_result.dart';

Future<void> showRiderRequestHideDialog(
  BuildContext context, {
  required Future<DeliveryActionResult> Function() onHide,
}) async {
  final reason = await showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      title: const Text('Why hide this request?'),
      children: [
        for (final reason in const [
          'Too far',
          'Delivery fee is too low',
          'Product load concern',
          'Route is unsuitable',
          'Schedule conflict',
          'Product-handling concern',
          'Other',
        ])
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, reason),
            child: Text(reason),
          ),
      ],
    ),
  );
  if (reason == null || !context.mounted) return;
  final result = await onHide();
  if (!context.mounted || result.isSuccess) return;
  ScaffoldMessenger.of(context).showAppSnackBar(
    SnackBar(content: Text(result.message ?? 'Request could not be hidden.')),
  );
}
