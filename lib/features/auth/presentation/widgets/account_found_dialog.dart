import 'package:agresell_app/features/auth/presentation/styles/account_found_dialog_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class AccountFoundDialog extends StatelessWidget {
  const AccountFoundDialog({super.key});

  static Future<bool> show(BuildContext context) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => const AccountFoundDialog(),
      ) ??
      false;

  @override
  Widget build(BuildContext context) => Dialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 28),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: Padding(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: AccountFoundDialogStyles.containerDecoration,
            child: const Icon(
              Icons.mail_outline_rounded,
              color: AgrisellColors.authGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Account Found',
            style: AccountFoundDialogStyles.accountFoundText,
          ),
          const SizedBox(height: 10),
          const Text(
            'This email is already registered, but your profile is not yet complete.',
            textAlign: TextAlign.center,
            style: AccountFoundDialogStyles.textStyle,
          ),
          const SizedBox(height: 12),
          const Text(
            'Would you like to continue completing your registration?',
            textAlign: TextAlign.center,
            style: AccountFoundDialogStyles.textStyle,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: AccountFoundDialogStyles.filledButtonStyle,
              child: const Text('Continue Registration'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context, false),
              style: AccountFoundDialogStyles.outlinedButtonStyle,
              child: const Text('Use a Different Email'),
            ),
          ),
        ],
      ),
    ),
  );
}
