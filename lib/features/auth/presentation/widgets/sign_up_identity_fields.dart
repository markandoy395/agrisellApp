import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/app_dropdown_style.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_input_style.dart';
import 'package:agresell_app/core/utils/philippine_phone_number.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';

class SignUpIdentityFields extends StatefulWidget {
  const SignUpIdentityFields({
    required this.firstNameController,
    required this.lastNameController,
    required this.extensionNameController,
    required this.contactNumberController,
    required this.dateOfBirthController,
    required this.genderController,
    required this.emailController,
    this.showEmail = true,
    super.key,
  });

  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController extensionNameController;
  final TextEditingController contactNumberController;
  final TextEditingController dateOfBirthController;
  final TextEditingController genderController;
  final TextEditingController emailController;
  final bool showEmail;

  @override
  State<SignUpIdentityFields> createState() => _SignUpIdentityFieldsState();
}

class _SignUpIdentityFieldsState extends State<SignUpIdentityFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final firstName = AuthTextField(
              controller: widget.firstNameController,
              hintText: 'First Name',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.givenName],
            );
            final lastName = AuthTextField(
              controller: widget.lastNameController,
              hintText: 'Last Name',
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.familyName],
            );
            if (constraints.maxWidth < 320) {
              return Column(
                children: [firstName, const SizedBox(height: 6), lastName],
              );
            }
            return Row(
              children: [
                Expanded(child: firstName),
                const SizedBox(width: 10),
                Expanded(child: lastName),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        AuthTextField(
          controller: widget.extensionNameController,
          hintText: 'Name Extension (Optional)',
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 6),
        AuthTextField(
          controller: widget.contactNumberController,
          hintText: 'Phone Number (09XXXXXXXXX)',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.telephoneNumber],
          inputFormatters: const [PhilippinePhoneNumberInputFormatter()],
        ),
        PhoneNumberSyncControl(controller: widget.contactNumberController),
        const SizedBox(height: 6),
        AuthTextField(
          controller: widget.dateOfBirthController,
          hintText: 'Date of Birth',
          keyboardType: TextInputType.datetime,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.birthday],
          readOnly: true,
          onTap: () => _selectDateOfBirth(context),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          isExpanded: true,
          dropdownColor: AppDropdownStyle.menuColor,
          borderRadius: AppDropdownStyle.menuBorderRadius,
          style: AppDropdownStyle.textStyle,
          iconEnabledColor: AppDropdownStyle.iconColor,
          initialValue: widget.genderController.text.isEmpty
              ? null
              : widget.genderController.text,
          decoration: AuthInputStyle.decoration(
            label: 'Gender',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(
              value: 'Prefer not to say',
              child: Text('Prefer not to say'),
            ),
          ],
          onChanged: (value) =>
              setState(() => widget.genderController.text = value ?? ''),
        ),
        const SizedBox(height: 6),
        if (widget.showEmail)
          AuthTextField(
            controller: widget.emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
          ),
      ],
    );
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final today = DateUtils.dateOnly(DateTime.now());
    final selected = await showDatePicker(
      context: context,
      helpText: 'Select date of birth',
      initialDate:
          DateTime.tryParse(widget.dateOfBirthController.text) ??
          DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: today,
    );
    if (selected == null) return;
    widget.dateOfBirthController.text =
        '${selected.year.toString().padLeft(4, '0')}-'
        '${selected.month.toString().padLeft(2, '0')}-'
        '${selected.day.toString().padLeft(2, '0')}';
  }
}
