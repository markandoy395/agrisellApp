import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_found_dialog.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';

class SignUpFlowCoordinator {
  const SignUpFlowCoordinator({
    required this.role,
    this.registrationService,
    this.sessionService,
  });

  final AuthRole role;
  final AuthRegistrationService? registrationService;
  final AuthSessionService? sessionService;

  AuthRegistrationService get _authService =>
      registrationService ?? AuthRegistrationService.instance;

  AuthSessionService get _session =>
      sessionService ?? AuthSessionService.instance;

  Future<bool> verifySignupEmail(
    BuildContext context, {
    required String email,
    required VoidCallback onChangeDestination,
  }) async {
    final verified = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => OtpVerificationScreen(
          destination: email,
          title: 'Verify your Buyer email',
          changeDestinationLabel: 'Change email',
          onChangeDestination: onChangeDestination,
          onVerify: (otp) => _authService.verifySignupEmailOtp(
            email: email,
            otp: otp,
            role: role,
          ),
          onResend: () => _authService.resendSignupEmailOtp(email),
        ),
      ),
    );
    return verified == true;
  }

  Future<bool> handleFoundAccount(
    BuildContext context, {
    required String email,
    required AuthIncompleteRegistrationFound found,
    required void Function(String email) onOtpStarted,
    required void Function(String email) onVerified,
    required void Function(String message) onError,
  }) async {
    if (!context.mounted) return false;
    final continueRegistration = await AccountFoundDialog.show(context);
    if (!continueRegistration) {
      if (found.emailVerified) await _authService.signOut();
      return false;
    }
    if (!context.mounted) return false;
    if (found.emailVerified) {
      onVerified(email);
      return true;
    }
    try {
      await _authService.resendSignupEmailOtp(email);
      if (!context.mounted) return false;
      onOtpStarted(email);
      final verified = await verifySignupEmail(
        context,
        email: email,
        onChangeDestination: () {},
      );
      if (verified && context.mounted) {
        onVerified(email);
        return true;
      }
    } on AuthRegistrationException catch (error) {
      if (context.mounted) onError(error.message);
    }
    return false;
  }

  Future<void> executeCredentialsVerification(
    BuildContext context, {
    required String email,
    required String password,
    required bool isOtpStarted,
    required void Function(String email) onOtpStarted,
    required VoidCallback onResetOtpStarted,
    required void Function(String email) onVerified,
    required void Function(String message) onError,
  }) async {
    try {
      if (!isOtpStarted) {
        final requiresOtp = await _authService.startEmailVerification(
          email: email,
          password: password,
          role: role,
        );
        if (!context.mounted) return;
        if (!requiresOtp) {
          onVerified(email);
          return;
        }
        onOtpStarted(email);
      }
      final verified = await verifySignupEmail(
        context,
        email: email,
        onChangeDestination: onResetOtpStarted,
      );
      if (verified && context.mounted) {
        onVerified(email);
      }
    } on AuthIncompleteRegistrationFound catch (found) {
      await handleFoundAccount(
        context,
        email: email,
        found: found,
        onOtpStarted: onOtpStarted,
        onVerified: onVerified,
        onError: onError,
      );
    }
  }

  Future<RegisteredAccount> registerBuyer({
    required SignUpAccountData data,
  }) async {
    return _authService.usesSupabase
        ? await _authService.completeVerifiedBuyerRegistration(data)
        : await _authService.register(data, role);
  }

  Future<void> finishSignUp(
    BuildContext context, {
    required RegisteredAccount account,
  }) async {
    await _session.start(account, rememberMe: false);
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(
        builder: (_) => AuthDashboardRouter.destinationFor(
          account,
          initialMessage: 'Your ${role.label} account was created successfully.',
        ),
      ),
      (route) => false,
    );
  }
}
