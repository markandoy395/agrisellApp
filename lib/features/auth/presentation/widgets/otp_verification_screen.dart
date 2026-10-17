import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../controllers/otp_verification_controller.dart';
import 'otp_verification_view.dart';

/// A modern light-card OTP/PIN verification prompt structured after
/// contemporary auth flows, using Agrisell's signature white & green palette.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.destination,
    required this.onVerify,
    this.onResend,
    this.title = 'Verify your login',
    this.codeLength = 6,
    this.maxIncorrectAttempts = 5,
    this.resendCooldown = const Duration(seconds: 60),
    this.accentColor = AgrisellColors.authGreen,
    this.changeDestinationLabel,
    this.onChangeDestination,
    super.key,
  }) : assert(maxIncorrectAttempts > 0);

  final String destination;
  final Future<void> Function(String code) onVerify;
  final Future<void> Function()? onResend;
  final String title;
  final int codeLength;
  final int maxIncorrectAttempts;
  final Duration resendCooldown;
  final Color accentColor;
  final String? changeDestinationLabel;
  final VoidCallback? onChangeDestination;

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final OtpVerificationController _controller;
  bool _verificationInProgress = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = OtpVerificationController(widget.resendCooldown);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_verificationInProgress || _completed) return;
    _verificationInProgress = true;
    final route = ModalRoute.of(context);
    final navigator = Navigator.of(context);
    final verified = await _controller.verify(
      codeLength: widget.codeLength,
      maxIncorrectAttempts: widget.maxIncorrectAttempts,
      onVerify: widget.onVerify,
    );
    if (!mounted) return;
    if (!verified) {
      _verificationInProgress = false;
      return;
    }
    _completed = true;
    // A late callback must never pop signup or another replacement screen.
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      navigator.pop(true);
    } else {
      navigator.removeRoute(route, true);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) => OtpVerificationView(
      destination: widget.destination,
      title: widget.title,
      codeLength: widget.codeLength,
      maxIncorrectAttempts: widget.maxIncorrectAttempts,
      accentColor: widget.accentColor,
      changeDestinationLabel: widget.changeDestinationLabel,
      onChangeDestination: widget.onChangeDestination,
      controller: _controller,
      onVerify: _verify,
      onResend:
          _controller.secondsRemaining == 0 &&
              !_controller.isResending &&
              widget.onResend != null
          ? () => _controller.resend(widget.onResend!, widget.resendCooldown)
          : null,
    ),
  );
}
