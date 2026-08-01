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
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
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
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 38,
          decoration: BoxDecoration(
            color: isSelected
                ? AgrisellColors.authGreen.withValues(alpha: 0.1)
                : AgrisellColors.fieldFill,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AgrisellColors.authGreen
                  : AgrisellColors.borderLine,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: AgrisellColors.authGreen,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(value, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
