import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/core/utils/profile_identity_validator.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_profile_style.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_edit_fields.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileEditCard extends StatefulWidget {
  const ProfileEditCard({
    required this.profile,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onCancel;
  final ValueChanged<UserProfile> onSave;

  @override
  State<ProfileEditCard> createState() => _ProfileEditCardState();
}

class _ProfileEditCardState extends State<ProfileEditCard> {
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
  void didUpdateWidget(covariant ProfileEditCard oldWidget) {
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
    return BuyerProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Personal information',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: BuyerProfileStyle.ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Update your account details.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: BuyerProfileStyle.muted,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFCCD6DA),
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _validationError!,
                      style: ProfileTextStyles.validationError(context),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                AccountEditFields(
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
