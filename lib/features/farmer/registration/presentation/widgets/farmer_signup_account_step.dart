import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_field.dart';

class FarmerSignupAccountStep extends StatelessWidget {
  const FarmerSignupAccountStep({
    required this.controllers,
    required this.errors,
    required this.onChanged,
    this.readOnly = false,
    this.emailVerified = false,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final Map<String, String?> errors;
  final VoidCallback onChanged;
  final bool readOnly;
  final bool emailVerified;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Account information',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      const Text(
        'Use an email address you can access.',
        style: TextStyle(fontSize: 12),
      ),
      const SizedBox(height: 12),
      FarmerSignupField(
        label: 'Email',
        controller: controllers.email,
        leadingIcon: Icons.mail_outline,
        leadingIconBadge: true,
        keyboardType: TextInputType.emailAddress,
        error: errors['email'],
        readOnly: readOnly,
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Password',
        controller: controllers.password,
        leadingIcon: Icons.lock_outline,
        leadingIconBadge: true,
        password: true,
        error: errors['password'],
        readOnly: readOnly,
        onChanged: (_) => onChanged(),
      ),
      AuthPasswordRequirements(controller: controllers.password),
      const SizedBox(height: 8),
      FarmerSignupField(
        label: 'Confirm password',
        controller: controllers.confirmPassword,
        leadingIcon: Icons.lock_outline,
        leadingIconBadge: true,
        password: true,
        error: errors['confirmPassword'],
        readOnly: readOnly,
        onChanged: (_) => onChanged(),
      ),
      if (readOnly)
        Text(
          emailVerified
              ? 'Email verified. Your account credentials are locked for this registration.'
              : 'OTP sent. Use Change email on the verification screen to edit these credentials.',
          style: const TextStyle(fontSize: 12),
        ),
    ],
  );
}
