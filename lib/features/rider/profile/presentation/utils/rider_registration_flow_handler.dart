import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_found_dialog.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';

abstract final class RiderRegistrationFlowHandler {
  static Future<void> handleContinue({
    required BuildContext context,
    required RiderSignUpController controller,
    required ValueChanged<RiderProfile> onSubmitted,
    required Future<bool> Function(String email, VoidCallback onChangeDestination)
        onEmailOtpRequired,
    required Future<bool> Function(String email, String password)
        onStartEmailVerification,
    required String? otpStartedFor,
    required void Function(String? email) onOtpStartedChanged,
    required void Function(bool verifying) onVerifyingEmailChanged,
    required bool Function() isMounted,
  }) async {
    if (controller.draft.step == RiderSignUpStep.account) {
      await handleAccountStep(
        context: context,
        controller: controller,
        onStartEmailVerification: onStartEmailVerification,
        onEmailOtpRequired: onEmailOtpRequired,
        otpStartedFor: otpStartedFor,
        onOtpStartedChanged: onOtpStartedChanged,
        onVerifyingEmailChanged: onVerifyingEmailChanged,
        isMounted: isMounted,
      );
      return;
    }
    if (controller.draft.step != RiderSignUpStep.review) {
      await controller.continueToNextStep();
      return;
    }
    if (!controller.validateForSubmission()) return;
    final profile = await controller.submit();
    if (profile != null && isMounted()) {
      onSubmitted(profile);
      return;
    }
    if (!controller.awaitingEmailOtp || !isMounted()) return;
    final verified = await onEmailOtpRequired(
      controller.draft.value(RiderSignUpFields.email),
      () {},
    );
    if (!verified || !isMounted()) return;
    final completed = await controller.submit();
    if (completed != null && isMounted()) {
      onSubmitted(completed);
    }
  }

  static Future<void> handleAccountStep({
    required BuildContext context,
    required RiderSignUpController controller,
    required Future<bool> Function(String email, String password)
        onStartEmailVerification,
    required Future<bool> Function(String email, VoidCallback onChangeDestination)
        onEmailOtpRequired,
    required String? otpStartedFor,
    required void Function(String? email) onOtpStartedChanged,
    required void Function(bool verifying) onVerifyingEmailChanged,
    required bool Function() isMounted,
  }) async {
    final email = controller.draft
        .value(RiderSignUpFields.email)
        .trim()
        .toLowerCase();
    if (controller.emailVerified) {
      await controller.continueToNextStep();
      return;
    }
    if (!controller.canContinue) {
      await controller.continueToNextStep();
      return;
    }

    onVerifyingEmailChanged(true);
    try {
      if (otpStartedFor != email) {
        final requiresOtp = await onStartEmailVerification(
          email,
          controller.password,
        );
        if (!isMounted()) return;
        if (!requiresOtp) {
          controller.markEmailVerified(email);
          await controller.continueToNextStep();
          return;
        }
        onOtpStartedChanged(email);
      }
      final verified = await onEmailOtpRequired(email, () {
        if (isMounted()) onOtpStartedChanged(null);
      });
      if (!verified || !isMounted()) return;
      onOtpStartedChanged(null);
      controller.markEmailVerified(email);
      await controller.continueToNextStep();
    } on AuthIncompleteRegistrationFound catch (found) {
      await resumeFoundAccount(
        context: context,
        email: email,
        found: found,
        controller: controller,
        onEmailOtpRequired: onEmailOtpRequired,
        onOtpStartedChanged: onOtpStartedChanged,
        isMounted: isMounted,
      );
    } on AuthRegistrationException catch (error) {
      controller.showEmailVerificationError(error.message);
    } catch (_) {
      controller.showEmailVerificationError(
        'We could not verify your email. Please try again.',
      );
    } finally {
      if (isMounted()) onVerifyingEmailChanged(false);
    }
  }

  static Future<void> resumeFoundAccount({
    required BuildContext context,
    required String email,
    required AuthIncompleteRegistrationFound found,
    required RiderSignUpController controller,
    required Future<bool> Function(String email, VoidCallback onChangeDestination)
        onEmailOtpRequired,
    required void Function(String? email) onOtpStartedChanged,
    required bool Function() isMounted,
  }) async {
    if (!isMounted()) return;
    final continueRegistration = await AccountFoundDialog.show(context);
    if (!continueRegistration) {
      if (found.emailVerified) {
        await AuthRegistrationService.instance.signOut();
      }
      return;
    }
    if (!isMounted()) return;
    if (found.emailVerified) {
      controller.markEmailVerified(email);
      await controller.continueToNextStep();
      return;
    }
    try {
      await AuthRegistrationService.instance.resendSignupEmailOtp(email);
      if (!isMounted()) return;
      onOtpStartedChanged(email);
      final verified = await onEmailOtpRequired(email, () {
        if (isMounted()) onOtpStartedChanged(null);
      });
      if (!verified || !isMounted()) return;
      onOtpStartedChanged(null);
      controller.markEmailVerified(email);
      await controller.continueToNextStep();
    } on AuthRegistrationException catch (error) {
      controller.showEmailVerificationError(error.message);
    }
  }
}
