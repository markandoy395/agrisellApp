import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

/// A reusable full-screen OTP/PIN prompt for signup, password recovery, and
/// other email or SMS verification flows.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    required this.destination,
    required this.onVerify,
    this.onResend,
    this.title = 'We just sent a code',
    this.codeLength = 6,
    this.maxIncorrectAttempts = 5,
    this.resendCooldown = const Duration(seconds: 60),
    this.accentColor = AgrisellColors.authGreen,
    this.changeDestinationLabel,
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

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final TextEditingController _code;
  late final FocusNode _focusNode;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isVerifying = false;
  bool _isResending = false;
  int _incorrectAttempts = 0;
  String? _error;
  String? _status;

  bool get _attemptsExhausted =>
      _incorrectAttempts >= widget.maxIncorrectAttempts;

  @override
  void initState() {
    super.initState();
    _code = TextEditingController();
    _focusNode = FocusNode();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _code.text;
    return Scaffold(
      backgroundColor: AgrisellColors.authBackground,
      appBar: AppBar(
        backgroundColor: AgrisellColors.authBackground,
        elevation: 0,
        surfaceTintColor: AgrisellColors.authBackground,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Material(
            color: AgrisellColors.forestSoft,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Back',
              color: AgrisellColors.forestGreen,
              onPressed: _isVerifying
                  ? null
                  : () => Navigator.of(context).pop(false),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 48, 28, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.mark_email_read_outlined,
                    size: 46,
                    color: widget.accentColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Enter the security code we sent to',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.destination,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AgrisellColors.headingGreen,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The code expires soon and can only be used once.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _OtpCodeBoxes(
                    code: code,
                    length: widget.codeLength,
                    accentColor: widget.accentColor,
                    hasError: _error != null,
                    focusNode: _focusNode,
                    controller: _code,
                    onChanged: (_) => setState(() {
                      _error = null;
                      _status = null;
                    }),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AgrisellColors.statusRedText,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_status != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _status!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 38,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: _isVerifying || _attemptsExhausted
                          ? null
                          : _verify,
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Verify'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Didn't receive code?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AgrisellColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed:
                        _secondsRemaining == 0 &&
                            !_isResending &&
                            widget.onResend != null
                        ? _resend
                        : null,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _secondsRemaining == 0
                                ? 'Resend code'
                                : 'Resend in ${_clockText(_secondsRemaining)}',
                          ),
                  ),
                  if (widget.changeDestinationLabel != null)
                    TextButton(
                      onPressed: _isVerifying || _isResending
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(widget.changeDestinationLabel!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length != widget.codeLength) {
      setState(() => _error = 'Enter the ${widget.codeLength}-digit code.');
      return;
    }
    setState(() {
      _isVerifying = true;
      _error = null;
      _status = null;
    });
    try {
      await widget.onVerify(code);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        if (error is AuthOtpException) {
          if (error.reason == AuthOtpFailureReason.invalid ||
              error.reason == AuthOtpFailureReason.expired) {
            _incorrectAttempts++;
          } else if (error.reason == AuthOtpFailureReason.tooManyAttempts) {
            _incorrectAttempts = widget.maxIncorrectAttempts;
          }
        }
        _error = _attemptsExhausted
            ? 'Too many incorrect attempts. Request a new OTP to continue.'
            : _safeErrorMessage(error, verifying: true);
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    final resend = widget.onResend;
    if (resend == null) return;
    setState(() => _isResending = true);
    try {
      await resend();
      _code.clear();
      _startCooldown();
      if (mounted) {
        setState(() {
          _incorrectAttempts = 0;
          _error = null;
          _status = 'A new OTP was sent to your email.';
        });
      }
    } catch (error) {
      if (error is AuthOtpException &&
          error.reason == AuthOtpFailureReason.tooManyAttempts) {
        _startCooldown();
      }
      if (mounted) {
        setState(() {
          _status = null;
          _error = _safeErrorMessage(error, verifying: false);
        });
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _startCooldown() {
    _timer?.cancel();
    _secondsRemaining = widget.resendCooldown.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsRemaining = 0);
        return;
      }
      setState(() => _secondsRemaining--);
    });
  }

  String _clockText(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  String _safeErrorMessage(Object error, {required bool verifying}) =>
      error is AuthRegistrationException
      ? error.message
      : verifying
      ? 'We could not verify the OTP. Please try again.'
      : 'We could not resend the OTP. Please try again.';
}

class _OtpCodeBoxes extends StatelessWidget {
  const _OtpCodeBoxes({
    required this.code,
    required this.length,
    required this.accentColor,
    required this.hasError,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
  });

  final String code;
  final int length;
  final Color accentColor;
  final bool hasError;
  final FocusNode focusNode;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$length digit verification code',
    textField: true,
    child: GestureDetector(
      onTap: focusNode.requestFocus,
      child: SizedBox(
        height: 52,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(length, (index) {
                final value = index < code.length ? code[index] : '';
                final isCurrent = index == code.length && focusNode.hasFocus;
                final border = hasError
                    ? AgrisellColors.statusRedText
                    : isCurrent
                    ? accentColor
                    : AgrisellColors.borderLine;
                return Container(
                  height: 48,
                  width: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: border,
                      width: isCurrent ? 1.6 : 1,
                    ),
                  ),
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLength: length,
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    counterText: '',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
