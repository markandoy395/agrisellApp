import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_password_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';

class RiderPasswordChange {
  const RiderPasswordChange({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;
}

Future<RiderPasswordChange?> showRiderPasswordChangeDialog(
  BuildContext context,
) async {
  final current = TextEditingController();
  final next = TextEditingController();
  final confirm = TextEditingController();
  String? error;
  final change = await showDialog<RiderPasswordChange>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PasswordField(controller: current, label: 'Current password'),
            _PasswordField(controller: next, label: 'New password'),
            AuthPasswordRequirements(controller: next),
            const SizedBox(height: 8),
            _PasswordField(controller: confirm, label: 'Confirm new password'),
            if (error != null)
              Text(error!, style: SharedPresentationStyles.errorCaption),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!PasswordPolicy.isStrong(next.text) ||
                  next.text != confirm.text) {
                setDialogState(
                  () => error =
                      'Use matching passwords that meet all requirements.',
                );
                return;
              }
              Navigator.of(context).pop(
                RiderPasswordChange(
                  currentPassword: current.text,
                  newPassword: next.text,
                ),
              );
            },
            child: const Text('Update password'),
          ),
        ],
      ),
    ),
  );
  current.dispose();
  next.dispose();
  confirm.dispose();
  return change;
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: TextField(
      controller: controller,
      obscureText: true,
      decoration: RiderPasswordDialogStyles.inputDecoration(label),
    ),
  );
}
