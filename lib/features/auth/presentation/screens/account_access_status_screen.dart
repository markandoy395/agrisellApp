import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

class AccountAccessStatusScreen extends StatelessWidget {
  const AccountAccessStatusScreen({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AgrisellColors.homeBackground,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 52,
                color: AgrisellColors.authGreen,
              ),
              const SizedBox(height: 16),
              const Text(
                'Account access restricted',
                textAlign: TextAlign.center,
                style: SharedPresentationStyles.titleBold,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: SharedPresentationStyles.caption,
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 40,
                child: FilledButton(
                  onPressed: () => _returnToLogin(context),
                  child: const Text('Return to login'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _returnToLogin(BuildContext context) async {
    await AuthSessionService.instance.clear();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
