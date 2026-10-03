import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_edit_fields_styles.dart';

class FarmerProfileEditActions extends StatelessWidget {
  const FarmerProfileEditActions({
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
          style: FarmerProfileEditFieldsStyles.cancelButtonStyle,
          child: const Text(
            'Cancel',
            textAlign: TextAlign.center,
            style: FarmerProfileEditFieldsStyles.buttonTextStyle,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 3,
        child: FilledButton(
          onPressed: onSave,
          style: FarmerProfileEditFieldsStyles.saveButtonStyle,
          child: const Text(
            'Save changes',
            textAlign: TextAlign.center,
            style: FarmerProfileEditFieldsStyles.buttonTextStyle,
          ),
        ),
      ),
    ],
  );
}
