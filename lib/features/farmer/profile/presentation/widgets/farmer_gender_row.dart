import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_row_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerGenderRow extends StatelessWidget {
  const FarmerGenderRow({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ProfileEditRow(
      label: 'Gender',
      child: Row(
        children: [
          FarmerGenderOption(
            label: 'Male',
            isSelected: value == 'Male',
            onTap: () => onChanged('Male'),
          ),
          const SizedBox(width: 16),
          FarmerGenderOption(
            label: 'Female',
            isSelected: value == 'Female',
            onTap: () => onChanged('Female'),
          ),
        ],
      ),
    );
  }
}

class FarmerGenderOption extends StatelessWidget {
  const FarmerGenderOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: Row(
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
        ),
      ),
    );
  }
}
