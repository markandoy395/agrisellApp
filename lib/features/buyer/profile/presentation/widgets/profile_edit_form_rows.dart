import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_row_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileEditFieldRow extends StatelessWidget {
  const ProfileEditFieldRow({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.readOnly = false,
    this.inputFormatters,
    this.trailing,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ProfileEditRow(
      label: label,
      child: ProfileEditPill(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                readOnly: readOnly,
                inputFormatters: inputFormatters,
                textAlignVertical: TextAlignVertical.center,
                style: ProfileTextStyles.infoValue(context),
                cursorColor: AgrisellColors.authGreen,
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing!],
          ],
        ),
      ),
    );
  }
}

class ProfileGenderRow extends StatelessWidget {
  const ProfileGenderRow({required this.value, super.key});

  final String value;

  @override
  Widget build(BuildContext context) {
    return ProfileEditRow(
      label: 'Gender',
      child: Row(
        children: [
          _ProfileGenderOption(label: 'Male', isSelected: value == 'Male'),
          const SizedBox(width: 16),
          _ProfileGenderOption(label: 'Female', isSelected: value == 'Female'),
        ],
      ),
    );
  }
}

class _ProfileGenderOption extends StatelessWidget {
  const _ProfileGenderOption({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSelected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded,
          color: AgrisellColors.authGreen,
          size: 17,
        ),
        const SizedBox(width: 5),
        Text(label, style: ProfileTextStyles.infoValue(context)),
      ],
    );
  }
}
