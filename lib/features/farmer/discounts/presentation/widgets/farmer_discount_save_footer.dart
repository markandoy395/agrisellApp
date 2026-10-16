import 'package:flutter/material.dart';

import '../styles/farmer_discount_dialog_styles.dart';

class FarmerDiscountSaveFooter extends StatelessWidget {
  const FarmerDiscountSaveFooter({
    super.key,
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
  });

  final bool isSaving;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: FarmerDiscountDialogStyles.footerPadding,
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: isSaving ? null : onSave,
          style: FarmerDiscountDialogStyles.saveButton,
          child: isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: FarmerDiscountDialogStyles.white,
                  ),
                )
              : Text(
                  isEditing ? 'Update Promotion' : 'Save & Apply Discount',
                  style: FarmerDiscountDialogStyles.saveLabel,
                ),
        ),
      ),
    ),
  );
}
