import 'package:flutter/material.dart';
import '../styles/farmer_discount_dialog_styles.dart';

class FarmerDiscountTypeChoice extends StatelessWidget {
  const FarmerDiscountTypeChoice({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      borderRadius: FarmerDiscountDialogStyles.choiceRadius,
      child: Container(
        padding: FarmerDiscountDialogStyles.choicePadding,
        decoration: isSelected
            ? FarmerDiscountDialogStyles.choiceSelected
            : FarmerDiscountDialogStyles.choiceUnselected,
        child: Center(
          child: Text(
            label,
            style: isSelected
                ? FarmerDiscountDialogStyles.choiceTextSelected
                : FarmerDiscountDialogStyles.choiceTextUnselected,
          ),
        ),
      ),
    ),
  );
}
