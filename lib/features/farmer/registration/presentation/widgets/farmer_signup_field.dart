import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/farmer/registration/presentation/styles/farmer_signup_field_styles.dart';

export 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_image_picker_button.dart';

class FarmerSignupField extends StatelessWidget {
  const FarmerSignupField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
    this.keyboardType,
    this.inputFormatters,
    this.password = false,
    this.leadingIcon,
    this.leadingIconBadge = false,
    this.leadingIconDivider = true,
    this.trailingIcon,
    this.readOnly = false,
    this.enabled = true,
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
  final IconData? leadingIcon;
  final bool leadingIconBadge;
  final bool leadingIconDivider;
  final IconData? trailingIcon;
  final bool readOnly;
  final bool enabled;
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
        leadingIcon: leadingIcon,
        leadingIconBadge: leadingIconBadge,
        leadingIconDivider: leadingIconDivider,
        trailingIcon: trailingIcon,
        readOnly: readOnly,
        enabled: enabled,
        onTap: onTap,
        onChanged: onChanged,
      ),
      if (error != null)
        Padding(
          padding: FarmerSignupFieldStyles.errorPadding,
          child: Text(
            error!,
            style: FarmerSignupFieldStyles.errorStyle,
          ),
        ),
      FarmerSignupFieldStyles.bottomSpacing,
    ],
  );
}
