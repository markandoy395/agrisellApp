import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/farmer/profile/presentation/styles/farmer_profile_edit_fields_styles.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_date_row.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_edit_actions.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_profile_text_field.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

class FarmerProfileEditFields extends StatelessWidget {
  const FarmerProfileEditFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.extensionNameController,
    required this.phoneController,
    required this.emailController,
    required this.birthDate,
    required this.onBirthDateChanged,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController extensionNameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final ProfileBirthDate birthDate;
  final ValueChanged<ProfileBirthDate> onBirthDateChanged;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  static InputDecoration decoration({
    String? hint,
    IconData? icon,
  }) => FarmerProfileEditFieldsStyles.decoration(hint: hint, icon: icon);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final first = FarmerProfileTextField(
            label: 'First name',
            controller: firstNameController,
          );
          final last = FarmerProfileTextField(
            label: 'Last name',
            controller: lastNameController,
          );
          if (constraints.maxWidth < 280 ||
              MediaQuery.textScalerOf(context).scale(14) > 19) {
            return Column(
              children: [
                first,
                FarmerProfileEditFieldsStyles.fieldSpacing,
                last,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: first),
              const SizedBox(width: 16),
              Expanded(child: last),
            ],
          );
        },
      ),
      FarmerProfileEditFieldsStyles.fieldSpacing,
      FarmerProfileTextField(
        label: 'Name extension',
        controller: extensionNameController,
        optional: true,
        hint: 'e.g., Jr., Sr., III',
      ),
      FarmerProfileEditFieldsStyles.fieldSpacing,
      FarmerProfileTextField(
        label: 'Phone number',
        controller: phoneController,
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
      ),
      FarmerProfileEditFieldsStyles.smallSpacing,
      PhoneNumberSyncControl(controller: phoneController, spacious: true),
      FarmerProfileEditFieldsStyles.sectionSpacing,
      FarmerProfileDateRow(
        birthDate: birthDate,
        onBirthDateChanged: onBirthDateChanged,
      ),
      FarmerProfileEditFieldsStyles.fieldSpacing,
      FarmerProfileTextField(
        label: 'Email',
        controller: emailController,
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
        readOnly: true,
      ),
      FarmerProfileEditFieldsStyles.actionsSpacing,
      FarmerProfileEditActions(onCancel: onCancel, onSave: onSave),
    ],
  );
}
