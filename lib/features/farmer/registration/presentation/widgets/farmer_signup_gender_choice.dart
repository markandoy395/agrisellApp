import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_gender_choice_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
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
        const Text('Gender', style: FarmerSignupGenderChoiceStyles.genderText),
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
          decoration:
              FarmerSignupGenderChoiceStyles.animatedContainerDecoration(
                isSelected,
              ),
          child: Row(
            children: [
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: FarmerSignupGenderChoiceStyles.containerDecoration,
                child: Icon(
                  value == 'Male' ? Icons.male_rounded : Icons.female_rounded,
                  color: AgrisellColors.authGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(value, style: SharedPresentationStyles.body),
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
