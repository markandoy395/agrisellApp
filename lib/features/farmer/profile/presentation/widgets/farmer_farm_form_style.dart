import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import '../styles/farmer_farm_form_styles.dart';

class FarmerFarmField extends StatelessWidget {
  const FarmerFarmField({
    required this.label,
    required this.icon,
    required this.controller,
    this.required = true,
    this.keyboardType,
    super.key,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool required;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) => Padding(
    padding: FarmerFarmFormStyles.fieldPadding,
    child: Semantics(
      label: required ? '$label, required' : '$label, optional',
      child: AuthTextField(
        key: ValueKey('farm-$label'),
        hintText: required ? '$label *' : '$label (optional)',
        leadingIcon: icon,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
      ),
    ),
  );
}
