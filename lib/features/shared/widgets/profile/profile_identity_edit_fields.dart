import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_date_of_birth_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_edit_action_button.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_edit_form_rows.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

class ProfileIdentityEditFields extends StatelessWidget {
  const ProfileIdentityEditFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.extensionNameController,
    required this.phoneController,
    required this.birthDate,
    required this.emailController,
    required this.onBirthDateChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController extensionNameController;
  final TextEditingController phoneController;
  final ProfileBirthDate birthDate;
  final TextEditingController emailController;
  final ValueChanged<ProfileBirthDate> onBirthDateChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileEditFieldRow(
          label: 'First Name',
          controller: firstNameController,
        ),
        ProfileEditFieldRow(label: 'Last Name', controller: lastNameController),
        ProfileEditFieldRow(
          label: 'Name Extension (Optional)',
          controller: extensionNameController,
        ),
        ProfileEditFieldRow(
          label: 'Phone Number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
        ),
        PhoneNumberSyncControl(controller: phoneController),
        ProfileDateOfBirthRow(
          value: birthDate,
          onDayChanged: (day) =>
              onBirthDateChanged(birthDate.copyWith(day: day)),
          onMonthChanged: (month) =>
              onBirthDateChanged(birthDate.copyWith(month: month)),
          onYearChanged: (year) =>
              onBirthDateChanged(birthDate.copyWith(year: year)),
        ),
        ProfileEditFieldRow(
          label: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          readOnly: true,
        ),
        const SizedBox(height: 13),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileEditActionButton(
              label: 'Cancel',
              onPressed: onCancel,
              isPrimary: false,
            ),
            const SizedBox(width: 14),
            ProfileEditActionButton(
              label: 'Save',
              onPressed: onSave,
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }
}
