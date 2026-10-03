import 'package:flutter/material.dart';

import '../styles/farmer_farm_edit_styles.dart';

class FarmerFarmEditActions extends StatelessWidget {
  const FarmerFarmEditActions({
    required this.isSaving,
    required this.isCapturing,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final bool isCapturing;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FarmerFarmEditStyles.spacingActionsTop,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: OutlinedButton(
                onPressed: isSaving ? null : onCancel,
                style: FarmerFarmEditStyles.cancelButtonStyle,
                child: const Text(
                  'Cancel',
                  style: FarmerFarmEditStyles.cancelButtonTextStyle,
                ),
              ),
            ),
            FarmerFarmEditStyles.spacingBetweenButtons,
            Flexible(
              child: FilledButton(
                onPressed: isSaving || isCapturing ? null : onSave,
                style: FarmerFarmEditStyles.saveButtonStyle,
                child: Text(
                  isSaving ? 'Saving...' : 'Save Farm',
                  textAlign: TextAlign.center,
                  style: FarmerFarmEditStyles.saveButtonTextStyle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
