import 'package:flutter/material.dart';

class FarmerDiscardDialog extends StatelessWidget {
  const FarmerDiscardDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => const FarmerDiscardDialog(),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Discard registration?'),
    content: const Text(
      'Your entered Farmer registration details will be lost.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Keep editing'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Discard'),
      ),
    ],
  );
}
