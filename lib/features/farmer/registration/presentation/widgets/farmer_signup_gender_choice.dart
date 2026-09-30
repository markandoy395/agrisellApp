import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class FarmerSignupGenderChoice extends StatelessWidget {
  const FarmerSignupGenderChoice({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Color(0xFF075239),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _choice('Male')),
            const SizedBox(width: 10),
            Expanded(child: _choice('Female')),
          ],
        ),
      ],
    ),
  );

  Widget _choice(String value) {
    final isSelected = controller.text == value;
    return Semantics(
      button: true,
      selected: isSelected,
      label: value,
      child: InkWell(
        key: ValueKey('farmer-gender-${value.toLowerCase()}'),
        onTap: () {
          controller.text = value;
          onChanged();
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AgrisellColors.authGreen.withValues(alpha: 0.06)
                : AgrisellColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AgrisellColors.authGreen
                  : AgrisellColors.borderLine,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDF8F0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  value == 'Male' ? Icons.male_rounded : Icons.female_rounded,
                  color: AgrisellColors.authGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 13)),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected
                    ? AgrisellColors.authGreen
                    : AgrisellColors.mutedText,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
