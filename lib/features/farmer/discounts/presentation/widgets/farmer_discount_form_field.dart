import 'package:flutter/material.dart';

import '../styles/farmer_discount_dialog_styles.dart';

/// Shared label, optional helper, and input layout for promotion fields.
class FarmerDiscountFormField extends StatelessWidget {
  const FarmerDiscountFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final String? prefixText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: FarmerDiscountDialogStyles.fieldLabel),
      if (helperText != null) ...[
        const SizedBox(height: 2),
        Text(helperText!, style: FarmerDiscountDialogStyles.helper),
      ],
      const SizedBox(height: 6),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: FarmerDiscountDialogStyles.inputDecoration(
          hintText: hintText,
          prefixText: prefixText,
          suffixText: suffixText,
        ),
      ),
    ],
  );
}
