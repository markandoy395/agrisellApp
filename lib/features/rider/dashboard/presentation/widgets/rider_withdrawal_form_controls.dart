import 'package:flutter/material.dart';

import '../styles/rider_withdrawal_control_styles.dart';
import '../styles/rider_withdrawal_styles.dart';

class RiderWithdrawalTypeButton extends StatelessWidget {
  const RiderWithdrawalTypeButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: RiderWithdrawalControlStyles.controlRadius,
      child: Container(
        padding: RiderWithdrawalStyles.typePadding,
        decoration: isSelected
            ? RiderWithdrawalControlStyles.selectedType
            : RiderWithdrawalControlStyles.unselectedType,
        child: Row(
          mainAxisAlignment: RiderWithdrawalStyles.centeredRow,
          children: [
            Icon(
              icon,
              size: RiderWithdrawalStyles.typeIconSize,
              color: isSelected
                  ? RiderWithdrawalControlStyles.selectedIconColor
                  : RiderWithdrawalControlStyles.unselectedIconColor,
            ),
            const SizedBox(width: RiderWithdrawalStyles.inlineGap),
            Text(
              title,
              style: isSelected
                  ? RiderWithdrawalControlStyles.selectedTypeLabel
                  : RiderWithdrawalControlStyles.unselectedTypeLabel,
            ),
          ],
        ),
      ),
    );
  }
}

class RiderWithdrawalFormActions extends StatelessWidget {
  const RiderWithdrawalFormActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: RiderWithdrawalControlStyles.cancelButton,
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: RiderWithdrawalStyles.controlGap),
        Expanded(
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: RiderWithdrawalControlStyles.saveButton,
            child: isSaving
                ? const SizedBox(
                    width: RiderWithdrawalStyles.spinnerSize,
                    height: RiderWithdrawalStyles.spinnerSize,
                    child: CircularProgressIndicator(
                      strokeWidth: RiderWithdrawalStyles.spinnerStrokeWidth,
                      color: RiderWithdrawalStyles.spinnerColor,
                    ),
                  )
                : const Text(
                    'Save Method',
                    style: RiderWithdrawalStyles.saveLabel,
                  ),
          ),
        ),
      ],
    );
  }
}
