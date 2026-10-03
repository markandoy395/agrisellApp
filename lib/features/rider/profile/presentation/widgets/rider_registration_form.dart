import 'dart:async';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/auth/presentation/widgets/keyboard_adaptive_scroll_view.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_draft.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_registration_styles.dart';
import 'package:agresell_app/features/rider/profile/presentation/utils/rider_registration_flow_handler.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_registration_exit_dialog.dart';
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

  Future<bool> confirmExit() => RiderRegistrationExitDialog.show(
    context,
    controller: _controller,
    onExit: widget.onExit,
  );

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
          color: RiderRegistrationStyles.surfaceColor,
          borderRadius: RiderRegistrationStyles.modalBorderRadius,
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: RiderRegistrationStyles.headerPadding,
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Rider Sign-Up',
                        style: RiderRegistrationStyles.headerTitleStyle,
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
                  padding: RiderRegistrationStyles.scrollPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RiderSignUpHeader(step: step),
                      RiderRegistrationStyles.stepSpacing,
                      _stepBody(step),
                      if (_controller.errorMessage != null) ...[
                        RiderRegistrationStyles.errorSpacing,
                        Text(
                          _controller.errorMessage!,
                          style: RiderRegistrationStyles.errorMessageStyle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: RiderRegistrationStyles.actionsPadding,
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

  Future<void> _continue() => RiderRegistrationFlowHandler.handleContinue(
    context: context,
    controller: _controller,
    onSubmitted: widget.onSubmitted,
    onEmailOtpRequired: widget.onEmailOtpRequired,
    onStartEmailVerification: widget.onStartEmailVerification,
    otpStartedFor: _otpStartedFor,
    onOtpStartedChanged: (email) => setState(() => _otpStartedFor = email),
    onVerifyingEmailChanged: (val) => setState(() => _isVerifyingEmail = val),
    isMounted: () => mounted,
  );
}
