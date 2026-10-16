import 'package:flutter/material.dart';
import 'package:agresell_app/core/utils/password_policy.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import '../styles/rider_profile_design_styles.dart';

class RiderPasswordChange {
  const RiderPasswordChange({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;
}

Future<RiderPasswordChange?> showRiderPasswordChangeDialog(
  BuildContext context,
) => showDialog<RiderPasswordChange>(
  context: context,
  builder: (_) => const Dialog.fullscreen(child: _RiderPasswordForm()),
);

class _RiderPasswordForm extends StatefulWidget {
  const _RiderPasswordForm();
  @override
  State<_RiderPasswordForm> createState() => _RiderPasswordFormState();
}

class _RiderPasswordFormState extends State<_RiderPasswordForm> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    if (_current.text.isEmpty ||
        !PasswordPolicy.isStrong(_next.text) ||
        _next.text != _confirm.text) {
      setState(
        () => _error =
            'Enter your current password and matching new passwords that meet all requirements.',
      );
      return;
    }
    Navigator.pop(
      context,
      RiderPasswordChange(
        currentPassword: _current.text,
        newPassword: _next.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 18, 16),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                Expanded(
                  child: Text(
                    'Change password',
                    style: RiderProfileDesignStyles.heading,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 14),
                _PasswordField(controller: _current, label: 'Current password'),
                _PasswordField(controller: _next, label: 'New password'),
                AuthPasswordRequirements(controller: _next),
                const SizedBox(height: 20),
                _PasswordField(
                  controller: _confirm,
                  label: 'Confirm new password',
                ),
                if (_error != null)
                  Text(_error!, style: SharedPresentationStyles.errorCaption),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: RiderProfileDesignStyles.secondary,
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: RiderProfileDesignStyles.primary,
                        onPressed: _save,
                        child: const Text('Update password'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller, required this.label});
  final TextEditingController controller;
  final String label;
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  var _obscure = true;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(
      controller: widget.controller,
      obscureText: _obscure,
      enableSuggestions: false,
      autocorrect: false,
      style: RiderProfileDesignStyles.body,
      decoration: RiderProfileDesignStyles.input(
        widget.label,
        suffix: IconButton(
          tooltip:
              '${_obscure ? 'Show' : 'Hide'} ${widget.label.toLowerCase()}',
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
            _obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
        ),
      ),
    ),
  );
}
