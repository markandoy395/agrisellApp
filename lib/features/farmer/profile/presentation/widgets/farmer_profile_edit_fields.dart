import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_gender_row.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_date_of_birth_row.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_action_button.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/profile_edit_form_rows.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';
import 'package:agresell_app/features/shared/location/presentation/widgets/profile_location_picker_button.dart';

class FarmerProfileEditFields extends StatelessWidget {
  const FarmerProfileEditFields({
    required this.nameController,
    required this.emailController,
    required this.addressController,
    required this.phoneController,
    required this.birthDate,
    required this.gender,
    required this.showPhoneNumber,
    required this.onTogglePhoneNumber,
    required this.onGenderChanged,
    required this.onBirthDateChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final ProfileBirthDate birthDate;
  final String gender;
  final bool showPhoneNumber;
  final VoidCallback onTogglePhoneNumber;
  final ValueChanged<String> onGenderChanged;
  final ValueChanged<ProfileBirthDate> onBirthDateChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileEditFieldRow(label: 'Name', controller: nameController),
        ProfileEditFieldRow(
          label: 'Email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        ProfileEditFieldRow(
          label: 'Address',
          controller: addressController,
          trailing: ProfileLocationPickerButton.farmer(addressController),
        ),
        ProfileEditFieldRow(
          label: 'Phone Number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
          obscureText: !showPhoneNumber,
          inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
          trailing: GestureDetector(
            onTap: onTogglePhoneNumber,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                showPhoneNumber ? 'Hide' : 'Show',
                style: ProfileTextStyles.editButton(context),
              ),
            ),
          ),
        ),
        FarmerGenderRow(value: gender, onChanged: onGenderChanged),
        ProfileDateOfBirthRow(
          value: birthDate,
          onDayChanged: (day) =>
              onBirthDateChanged(birthDate.copyWith(day: day)),
          onMonthChanged: (month) =>
              onBirthDateChanged(birthDate.copyWith(month: month)),
          onYearChanged: (year) =>
              onBirthDateChanged(birthDate.copyWith(year: year)),
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
