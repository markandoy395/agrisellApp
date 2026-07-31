import 'package:flutter/material.dart';

Future<bool> confirmClearRiderNotifications(BuildContext context) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Clear all notifications?'),
          content: const Text(
            'Dismissible notifications will be removed from this device.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear all'),
            ),
          ],
        ),
      ) ??
      false;
}
