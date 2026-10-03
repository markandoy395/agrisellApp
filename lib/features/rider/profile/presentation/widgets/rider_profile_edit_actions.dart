import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/profile/presentation/styles/rider_profile_edit_styles.dart';

class RiderProfileEditActions extends StatelessWidget {
  const RiderProfileEditActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: RiderProfileEditStyles.actionButtonStyle,
            onPressed: onCancel,
            child: const Text('Cancel'),
          ),
        ),
        RiderProfileEditStyles.buttonRowSpacing,
        Expanded(
          child: FilledButton(
            style: RiderProfileEditStyles.saveButtonStyle,
            onPressed: isSaving ? null : onSave,
            child: isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save changes'),
          ),
        ),
      ],
    );
  }
}
