import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';

class RiderSignUpSecurityStep extends StatelessWidget {
  const RiderSignUpSecurityStep({required this.controller, super.key});
  final RiderSignUpController controller;

  @override
  Widget build(BuildContext context) {
    final password = controller.password;
    final requirements = PasswordPolicy.evaluate(password);
    final isStrong = PasswordPolicy.isStrong(password);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Create a strong password. It is kept only while this app session is open.',
          style: TextStyle(fontSize: 12, color: AgrisellColors.mutedText),
        ),
        const SizedBox(height: 12),
        RiderSignUpPasswordField(
          label: 'Password',
          value: password,
          onChanged: (value) => controller.updateSensitive(password: value),
        ),
        const SizedBox(height: 10),
        RiderSignUpPasswordField(
          label: 'Confirm password',
          value: controller.confirmPassword,
          error:
              controller.confirmPassword.isNotEmpty &&
                  controller.confirmPassword != password
              ? 'Passwords do not match.'
              : null,
          onChanged: (value) =>
              controller.updateSensitive(confirmPassword: value),
        ),
        if (!isStrong) ...[
          const SizedBox(height: 12),
          const Text(
            'Password requirements',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          for (final item in requirements)
            _Requirement(label: item.label, complete: item.isMet),
          if (password.isNotEmpty &&
              !RiderRegistrationValidator.isStrongPassword(password))
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Password is too weak.',
                style: TextStyle(
                  color: AgrisellColors.statusRedText,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ],
    );
  }
}

class RiderSignUpPasswordField extends StatefulWidget {
  const RiderSignUpPasswordField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.error,
    super.key,
  });
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? error;

  @override
  State<RiderSignUpPasswordField> createState() =>
      _RiderSignUpPasswordFieldState();
}

class _RiderSignUpPasswordFieldState extends State<RiderSignUpPasswordField> {
  var _hidden = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    key: ValueKey(widget.label),
    initialValue: widget.value,
    obscureText: _hidden,
    onChanged: widget.onChanged,
    style: const TextStyle(fontSize: 13),
    decoration: InputDecoration(
      labelText: widget.label,
      contentPadding: riderSignUpFieldContentPadding,
      errorText: widget.error,
      filled: true,
      fillColor: AgrisellColors.fieldFill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      suffixIcon: IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _hidden = !_hidden),
        icon: Icon(
          _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    ),
  );
}

class _Requirement extends StatelessWidget {
  const _Requirement({required this.label, required this.complete});
  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          complete ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
          size: 16,
          color: complete
              ? AgrisellColors.statusGreenText
              : AgrisellColors.mutedText,
        ),
        const SizedBox(width: 7),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    ),
  );
}
