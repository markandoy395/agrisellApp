import 'package:flutter/material.dart';

import '../styles/app_safety_sheet_styles.dart';

Future<bool?> showConfirmSosDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppSafetySheetStyles.sosWarningColor,
          ),
          AppSafetySheetStyles.spacingTitleIcon,
          const Text('Confirm Emergency SOS'),
        ],
      ),
      content: const Text(
        'This will immediately alert admin dispatch and emergency support with your account and order details. Are you in immediate distress?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          style: AppSafetySheetStyles.sosConfirmButtonStyle,
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Yes, Send SOS Alert'),
        ),
      ],
    ),
  );
}
