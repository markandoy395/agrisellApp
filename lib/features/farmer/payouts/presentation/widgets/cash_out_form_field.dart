import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../styles/cash_out_dialog_styles.dart';

class CashOutFormField extends StatelessWidget {
  const CashOutFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.isAmount = false,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool isAmount;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: CashOutDialogStyles.fieldLabel),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        decoration: CashOutDialogStyles.inputDecoration(
          hintText,
          isAmount: isAmount,
        ),
      ),
    ],
  );
}
