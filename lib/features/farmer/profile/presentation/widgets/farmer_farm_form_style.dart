import 'package:flutter/material.dart';
import 'farmer_profile_style.dart';

abstract final class FarmerFarmFormStyle {
  static const borderColor = Color(0xFFCBD3E2);
  static final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: borderColor),
  );
  static final decoration = InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: border,
    enabledBorder: border,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: FarmerProfileStyle.green, width: 1.5),
    ),
  );

  static Widget label(String text, IconData icon, {bool required = true}) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF18783E), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: text),
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              style: const TextStyle(
                color: FarmerProfileStyle.ink,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      );
}

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
            style: const TextStyle(fontSize: 14, color: FarmerProfileStyle.ink),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF8999B3)),
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
