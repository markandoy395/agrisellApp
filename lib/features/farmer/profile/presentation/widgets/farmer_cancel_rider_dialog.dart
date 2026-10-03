import 'package:flutter/material.dart';

Future<bool?> showFarmerCancelRiderDialog(
  BuildContext context, {
  required String riderName,
}) =>
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel rider request?'),
        content: Text('Cancel the pending request sent to $riderName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep request'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
