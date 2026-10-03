import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_edit_fields_styles.dart';

class FarmerProfileTextField extends StatelessWidget {
  const FarmerProfileTextField({
    required this.label,
    required this.controller,
    this.optional = false,
    this.hint,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final bool optional;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(label, style: FarmerProfileEditFieldsStyles.labelStyle),
          ),
          if (optional)
            const Text(
              'Optional',
              style: FarmerProfileEditFieldsStyles.optionalStyle,
            ),
        ],
      ),
      FarmerProfileEditFieldsStyles.smallSpacing,
      Semantics(
        label: label,
        child: TextField(
          key: ValueKey('farmer-edit-$label'),
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: keyboardType == null
              ? TextCapitalization.words
              : TextCapitalization.none,
          style: FarmerProfileEditFieldsStyles.inputStyle,
          decoration: FarmerProfileEditFieldsStyles.decoration(
            hint: hint,
            icon: icon,
          ),
        ),
      ),
    ],
  );
}
