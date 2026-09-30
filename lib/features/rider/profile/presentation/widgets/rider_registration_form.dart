import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/data/auth_registration_service.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_found_dialog.dart';
import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_address_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_documents_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_personal_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_review_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_security_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_vehicle_step.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_widgets.dart';
import 'package:agresell_app/features/shared/location/data/gps_location_gateway.dart';

class RiderRegistrationForm extends StatefulWidget {
  const RiderRegistrationForm({
    required this.onSubmitted,
    required this.onExit,
    required this.onEmailOtpRequired,
    required this.onStartEmailVerification,
    this.initialVerifiedEmail,
    this.controller,
    this.gpsGateway,
    super.key,
  });
  final ValueChanged<RiderProfile> onSubmitted;
  final Future<void> Function() onExit;
  final RiderSignUpController? controller;
  final GpsLocationGateway? gpsGateway;
  final Future<bool> Function(String email, VoidCallback onChangeDestination)
  onEmailOtpRequired;
  final Future<bool> Function(String email, String password)
  onStartEmailVerification;
  final String? initialVerifiedEmail;
  @override
  State<RiderRegistrationForm> createState() => RiderRegistrationFormState();
}

class RiderRegistrationFormState extends State<RiderRegistrationForm>
    with WidgetsBindingObserver {
  late final RiderSignUpController _controller;
  late final bool _ownsController;
  String? _otpStartedFor;
  var _isVerifyingEmail = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        RiderSignUpController(gpsGateway: widget.gpsGateway);
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    final verifiedEmail = widget.initialVerifiedEmail;
    if (verifiedEmail != null && verifiedEmail.trim().isNotEmpty) {
      await _controller.resumeVerifiedEmail(verifiedEmail);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_controller.saveNow());
    }
  }

  Future<bool> confirmExit() async {
    final choice = await showDialog<_ExitChoice>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Your Rider Sign-Up is not yet complete. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _ExitChoice.continueRegistration),
            child: const Text('Continue Registration'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.saveAndExit),
            child: const Text('Save and Exit'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _ExitChoice.discard),
            child: const Text('Discard Registration'),
          ),
        ],
      ),
    );
    if (choice == null || choice == _ExitChoice.continueRegistration) {
      return false;
    }
    if (choice == _ExitChoice.saveAndExit) {
      await _controller.saveNow();
    }
    if (choice == _ExitChoice.discard) {
      await _controller.discard();
    }
    await widget.onExit();
    return true;
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      if (_controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      final step = _controller.draft.step;
      final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: Material(
          color: AgrisellColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 14, 10),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Rider Sign-Up',
                        style: TextStyle(
                          color: AgrisellColors.authGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: confirmExit,
                      child: const Text('Save & Exit'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: KeyboardAdaptiveScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RiderSignUpHeader(step: step),
                      const SizedBox(height: 18),
                      _stepBody(step),
                      if (_controller.errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _controller.errorMessage!,
                          style: const TextStyle(
                            color: AgrisellColors.statusRedText,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                  child: RiderSignUpActions(
                    isFirst: step == RiderSignUpStep.account,
                    isLast: step == RiderSignUpStep.review,
                    enabled: _controller.canContinue,
                    loading:
                        _controller.isSubmitting ||
                        _controller.isCapturingLocation ||
                        _isVerifyingEmail,
                    onPrevious: () => unawaited(_controller.previousStep()),
                    onContinue: _continue,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  Widget _stepBody(RiderSignUpStep step) => switch (step) {
    RiderSignUpStep.account => RiderSignUpSecurityStep(
      controller: _controller,
      readOnly: _controller.emailVerified || _otpStartedFor != null,
    ),
    RiderSignUpStep.personal => RiderSignUpPersonalStep(
      controller: _controller,
    ),
    RiderSignUpStep.address => RiderSignUpAddressStep(controller: _controller),
    RiderSignUpStep.vehicle => RiderSignUpVehicleStep(controller: _controller),
    RiderSignUpStep.documents => RiderSignUpDocumentsStep(
      controller: _controller,
    ),
    RiderSignUpStep.review => RiderSignUpReviewStep(controller: _controller),
  };
  Future<void> _continue() async {
    if (_controller.draft.step == RiderSignUpStep.account) {
      await _continueFromAccount();
      return;
    }
    if (_controller.draft.step != RiderSignUpStep.review) {
      await _controller.continueToNextStep();
      return;
    }
    if (!_controller.validateForSubmission()) return;
    final profile = await _controller.submit();
    if (profile != null && mounted) {
      widget.onSubmitted(profile);
      return;
    }
    if (!_controller.awaitingEmailOtp || !mounted) return;
    final verified = await widget.onEmailOtpRequired(
      _controller.draft.value(RiderSignUpFields.email),
      () {},
    );
    if (!verified || !mounted) return;
    final completed = await _controller.submit();
    if (completed != null && mounted) widget.onSubmitted(completed);
  }

  Future<void> _continueFromAccount() async {
    final email = _controller.draft
        .value(RiderSignUpFields.email)
        .trim()
        .toLowerCase();
    if (_controller.emailVerified) {
      await _controller.continueToNextStep();
      return;
    }
    if (!_controller.canContinue) {
      await _controller.continueToNextStep();
      return;
    }

    setState(() => _isVerifyingEmail = true);
    try {
      if (_otpStartedFor != email) {
        final requiresOtp = await widget.onStartEmailVerification(
          email,
          _controller.password,
        );
        if (!mounted) return;
        if (!requiresOtp) {
          _controller.markEmailVerified(email);
          await _controller.continueToNextStep();
          return;
        }
        setState(() => _otpStartedFor = email);
      }
      final verified = await widget.onEmailOtpRequired(email, () {
        if (mounted) setState(() => _otpStartedFor = null);
      });
      if (!verified || !mounted) return;
      setState(() => _otpStartedFor = null);
      _controller.markEmailVerified(email);
      await _controller.continueToNextStep();
    } on AuthIncompleteRegistrationFound catch (found) {
      await _resumeFoundAccount(email, found);
    } on AuthRegistrationException catch (error) {
      _controller.showEmailVerificationError(error.message);
    } catch (_) {
      _controller.showEmailVerificationError(
        'We could not verify your email. Please try again.',
      );
    } finally {
      if (mounted) setState(() => _isVerifyingEmail = false);
    }
  }

  Future<void> _resumeFoundAccount(
    String email,
    AuthIncompleteRegistrationFound found,
  ) async {
    if (!mounted) return;
    final continueRegistration = await AccountFoundDialog.show(context);
    if (!continueRegistration) {
      if (found.emailVerified) await AuthRegistrationService.instance.signOut();
      return;
    }
    if (!mounted) return;
    if (found.emailVerified) {
      _controller.markEmailVerified(email);
      await _controller.continueToNextStep();
      return;
    }
    try {
      await AuthRegistrationService.instance.resendSignupEmailOtp(email);
      if (!mounted) return;
      setState(() => _otpStartedFor = email);
      final verified = await widget.onEmailOtpRequired(email, () {
        if (mounted) setState(() => _otpStartedFor = null);
      });
      if (!verified || !mounted) return;
      setState(() => _otpStartedFor = null);
      _controller.markEmailVerified(email);
      await _controller.continueToNextStep();
    } on AuthRegistrationException catch (error) {
      _controller.showEmailVerificationError(error.message);
    }
  }
}

enum _ExitChoice { continueRegistration, saveAndExit, discard }
