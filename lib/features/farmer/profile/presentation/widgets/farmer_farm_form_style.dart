export 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_farm_form_styles.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_farm_form_styles.dart';
import 'package:flutter/material.dart';

class FarmerFarmField extends StatelessWidget {
  const FarmerFarmField({
    required this.label,
    required this.icon,
    required this.controller,
    this.required = true,
    this.inline = false,
    this.hint,
    this.keyboardType,
    super.key,
  });
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool required;
  final bool inline;
  final String? hint;
  final TextInputType? keyboardType;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final caption = FarmerFarmFormStyle.label(
          label,
          icon,
          required: required,
        );
        final input = Semantics(
          label: label,
          child: TextField(
            key: ValueKey('farm-$label'),
            controller: controller,
            keyboardType: keyboardType,
            style: FarmerFarmFormStyles.textStyle3,
            decoration: FarmerFarmFormStyles.inputDecoration(
              hint,
            ).applyDefaults(FarmerFarmFormStyle.decoration),
          ),
        );
        if (inline &&
            constraints.maxWidth >= 320 &&
            MediaQuery.textScalerOf(context).scale(14) <= 18) {
          return Row(
            children: [
              Expanded(flex: 2, child: caption),
              const SizedBox(width: 12),
              Expanded(flex: 3, child: input),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [caption, const SizedBox(height: 8), input],
        );
      },
    ),
  );
}
