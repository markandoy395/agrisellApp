import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

import '../styles/farmer_information_request_styles.dart';
import '../styles/farmer_verification_form_styles.dart';

class FarmerVerificationTextField extends StatelessWidget {
  const FarmerVerificationTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: FarmerInformationRequestStyles.alignStart,
      children: [
        Text(label, style: FarmerInformationRequestStyles.fieldLabel),
        const SizedBox(height: FarmerInformationRequestStyles.labelGap),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: FarmerVerificationFormStyles.profileInput(
            Icon(
              icon,
              size: FarmerInformationRequestStyles.fieldIconSize,
              color: AgrisellColors.mutedText,
            ),
          ),
        ),
      ],
    );
  }
}
