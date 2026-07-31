import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/farmer/registration/presentation/controllers/farmer_signup_controllers.dart';
import 'package:agresell_app/features/farmer/registration/presentation/widgets/farmer_signup_field.dart';

class FarmerSignupAccountStep extends StatelessWidget {
  const FarmerSignupAccountStep({
    required this.controllers,
    required this.errors,
    required this.onChanged,
    super.key,
  });

  final FarmerSignupControllers controllers;
  final Map<String, String?> errors;
  final VoidCallback onChanged;

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
        keyboardType: TextInputType.emailAddress,
        error: errors['email'],
        onChanged: (_) => onChanged(),
      ),
      FarmerSignupField(
        label: 'Password',
        controller: controllers.password,
        password: true,
        error: errors['password'],
        onChanged: (_) => onChanged(),
      ),
      AuthPasswordRequirements(controller: controllers.password),
      const SizedBox(height: 8),
      FarmerSignupField(
        label: 'Confirm password',
        controller: controllers.confirmPassword,
        password: true,
        error: errors['confirmPassword'],
        onChanged: (_) => onChanged(),
      ),
    ],
  );
}
