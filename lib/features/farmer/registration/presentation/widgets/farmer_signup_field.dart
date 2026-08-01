import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authTextField.dart';

class FarmerSignupField extends StatelessWidget {
  const FarmerSignupField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
    this.keyboardType,
    this.inputFormatters,
    this.password = false,
    this.readOnly = false,
    this.onTap,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? error;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool password;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AuthTextField(
        hintText: label,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        showPasswordToggle: password,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
      ),
      if (error != null)
        Padding(
          padding: const EdgeInsets.only(top: 3, left: 4),
          child: Text(
            error!,
            style: const TextStyle(
              color: AgrisellColors.statusRedText,
              fontSize: 12,
            ),
          ),
        ),
      const SizedBox(height: 8),
    ],
  );
}

class FarmerImagePickerButton extends StatelessWidget {
  const FarmerImagePickerButton({
    required this.label,
    required this.hasImage,
    required this.onPressed,
    super.key,
  });

  final String label;
  final bool hasImage;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(
      hasImage
          ? Icons.check_circle_outline
          : Icons.add_photo_alternate_outlined,
    ),
    label: Text(hasImage ? '$label selected' : label),
    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 38)),
  );
}
