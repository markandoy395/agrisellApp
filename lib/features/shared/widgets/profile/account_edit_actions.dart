import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/widgets/profile/account_edit_fields_styles.dart';

class AccountEditActions extends StatelessWidget {
  const AccountEditActions({
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 2,
        child: OutlinedButton(
          onPressed: onCancel,
          style: AccountEditFieldsStyles.cancelButtonStyle,
          child: const Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: AccountEditFieldsStyles.buttonTextStyle,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: FilledButton(
          onPressed: onSave,
          style: AccountEditFieldsStyles.saveButtonStyle,
          child: const Text(
            'Save changes',
            textAlign: TextAlign.center,
            style: AccountEditFieldsStyles.buttonTextStyle,
          ),
        ),
      ),
    ],
  );
}
