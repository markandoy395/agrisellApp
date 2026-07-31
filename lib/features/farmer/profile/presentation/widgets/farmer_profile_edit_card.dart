import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/core/utils/profile_identity_validator.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_identity_edit_fields.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerProfileEditCard extends StatefulWidget {
  const FarmerProfileEditCard({
    required this.profile,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onCancel;
  final ValueChanged<UserProfile> onSave;

  @override
  State<FarmerProfileEditCard> createState() => _FarmerProfileEditCardState();
}

class _FarmerProfileEditCardState extends State<FarmerProfileEditCard> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _extensionNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late ProfileBirthDate _birthDate;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _extensionNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _syncProfileFields(widget.profile);
  }

  @override
  void didUpdateWidget(covariant FarmerProfileEditCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile == widget.profile) return;
    _syncProfileFields(widget.profile);
    _validationError = null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _extensionNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _syncProfileFields(UserProfile profile) {
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _extensionNameController.text = profile.extensionName;
    _phoneController.text = profile.phoneNumber;
    _birthDate = ProfileBirthDate.parse(profile.dateOfBirth);
    _emailController.text = profile.email;
  }

  void _setBirthDate(ProfileBirthDate value) {
    setState(() => _birthDate = value);
  }

  void _saveProfile() {
    final result = ProfileIdentityValidator.validate(
      baseProfile: widget.profile,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      extensionName: _extensionNameController.text,
      phoneNumber: _phoneController.text,
      dateOfBirth: _birthDate,
      email: _emailController.text,
    );
    final profile = result.profile;
    if (profile == null) {
      setState(() => _validationError = result.errorMessage);
      return;
    }

    widget.onSave(profile);
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionLabel(text: 'My Profile'),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Manage and protect your account',
                    style: ProfileTextStyles.profileDescription(context),
                  ),
                ),
                const SizedBox(height: 7),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AgrisellColors.dividerLine,
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 7),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _validationError!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: ProfileTextStyles.validationError(context),
                    ),
                  ),
                ],
                const SizedBox(height: 9),
                ProfileIdentityEditFields(
                  firstNameController: _firstNameController,
                  lastNameController: _lastNameController,
                  extensionNameController: _extensionNameController,
                  phoneController: _phoneController,
                  birthDate: _birthDate,
                  emailController: _emailController,
                  onBirthDateChanged: _setBirthDate,
                  onCancel: widget.onCancel,
                  onSave: _saveProfile,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
