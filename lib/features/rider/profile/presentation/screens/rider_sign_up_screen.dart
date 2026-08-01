import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/utils/responsive.dart';
import 'package:agresell_app/features/auth/presentation/screens/roleSelectionScreen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/authBackground.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logoHeader.dart';
import 'package:agresell_app/features/auth/data/authRegistrationService.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/presentation/screens/rider_application_submitted_screen.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_registration_form.dart';

class RiderSignUpScreen extends StatefulWidget {
  const RiderSignUpScreen({super.key});

  @override
  State<RiderSignUpScreen> createState() => _RiderSignUpScreenState();
}

class _RiderSignUpScreenState extends State<RiderSignUpScreen> {
  final _formKey = GlobalKey<RiderRegistrationFormState>();

  @override
  Widget build(BuildContext context) {
    final scale = authScale(MediaQuery.sizeOf(context).width);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => unawaited(_requestExit()),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const AuthBackground(),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  SizedBox(height: lerpDouble(18, 26, scale)),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Back to role selection',
                        onPressed: () => unawaited(_requestExit()),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                      ),
                      const Expanded(
                        child: LogoHeader(
                          style: LogoHeaderStyle.horizontal,
                          widthMin: 174,
                          widthMax: 220,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  SizedBox(height: lerpDouble(12, 18, scale)),
                  Expanded(
                    child: RiderRegistrationForm(
                      key: _formKey,
                      onExit: _exitToRoleSelection,
                      onSubmitted: _showSubmitted,
                      onEmailOtpRequired: _verifyEmailOtp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestExit() async {
    await _formKey.currentState?.confirmExit();
  }

  Future<void> _exitToRoleSelection() => Navigator.of(context).pushReplacement(
    agrisellPageRoute<void>(builder: (_) => const RoleSelectionScreen.signUp()),
  );

  void _showSubmitted(RiderProfile profile) {
    Navigator.of(context).pushReplacement(
      agrisellPageRoute<void>(
        builder: (_) => RiderApplicationSubmittedScreen(reference: profile.id),
      ),
    );
  }

  Future<bool> _verifyEmailOtp(String email) async {
    final verified = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => OtpVerificationScreen(
          destination: email,
          title: 'We just sent an email',
          onVerify: (otp) => AuthRegistrationService.instance.verifyEmailOtp(
            email: email,
            otp: otp,
          ),
          onResend: () =>
              AuthRegistrationService.instance.resendSignupEmailOtp(email),
        ),
      ),
    );
    return verified ?? false;
  }
}
