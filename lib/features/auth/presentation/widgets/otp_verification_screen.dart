import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

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
    _focusNode.addListener(_onFocusChange);
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
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
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Material(
              color: AgrisellColors.forestSoft,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Back',
                color: AgrisellColors.forestGreen,
                onPressed: _isVerifying
                    ? null
                    : () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 17),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AgrisellColors.borderLine,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 14,
                          height: 1.45,
                        ),
                        children: [
                          const TextSpan(
                            text:
                                'Enter the verification code we sent to your email address: ',
                          ),
                          TextSpan(
                            text: widget.destination,
                            style: const TextStyle(
                              color: AgrisellColors.headingGreen,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: Text(
                            'Verification code',
                            style: TextStyle(
                              color: AgrisellColors.headingGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _ResendButton(
                          isResending: _isResending,
                          cooldownSeconds: _secondsRemaining,
                          accentColor: widget.accentColor,
                          onPressed: _secondsRemaining == 0 &&
                                  !_isResending &&
                                  widget.onResend != null
                              ? _resend
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: _isVerifying || _isResending
                            ? null
                            : () {
                                if (widget.onChangeDestination != null) {
                                  widget.onChangeDestination!();
                                  Navigator.of(context).pop(false);
                                } else {
                                  _showNoAccessModal(context);
                                }
                              },
                        child: Text(
                          widget.changeDestinationLabel ??
                              'I no longer have access to this email address.',
                          style: TextStyle(
                            color: AgrisellColors.mutedText.withValues(alpha: 0.9),
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                            decorationColor:
                                AgrisellColors.mutedText.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AgrisellColors.statusRedBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AgrisellColors.statusRedText
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AgrisellColors.statusRedText,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(
                                  color: AgrisellColors.statusRedText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_status != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: AgrisellColors.statusGreenBackground,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                AgrisellColors.authGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AgrisellColors.forestGreen,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _status!,
                                style: const TextStyle(
                                  color: AgrisellColors.forestGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    const Divider(
                      color: AgrisellColors.borderLine,
                      height: 1,
                      thickness: 1,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              widget.accentColor.withValues(alpha: 0.35),
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
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
                                  strokeWidth: 2.2,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Having trouble signing in? ',
                            style: TextStyle(
                              color: AgrisellColors.mutedText,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _showSupportModal(context),
                            child: const Text(
                              'Contact support',
                              style: TextStyle(
                                color: AgrisellColors.headingGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                                decorationColor: AgrisellColors.headingGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSupportModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AgrisellColors.borderLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Need Help Signing In?',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'If you are having trouble receiving or entering your verification code, our support team is here to assist.',
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _supportTile(
                icon: Icons.email_outlined,
                title: 'Email Support',
                detail: 'support@agrisell.com',
              ),
              const SizedBox(height: 10),
              _supportTile(
                icon: Icons.phone_outlined,
                title: 'Support Hotline',
                detail: '+63 900 123 4567 (Mon-Fri 8AM-5PM)',
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 44,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AgrisellColors.forestSoft,
                    foregroundColor: AgrisellColors.headingGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoAccessModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AgrisellColors.borderLine,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Lost Access to Your Email?',
                style: TextStyle(
                  color: AgrisellColors.headingGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'If you can no longer access ${widget.destination}, please contact Agrisell support or go back to register with another email.',
                style: const TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AgrisellColors.headingGreen,
                          side: const BorderSide(
                              color: AgrisellColors.borderLine),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop(false);
                        },
                        child: const Text(
                          'Go back',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.accentColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showSupportModal(context);
                        },
                        child: const Text(
                          'Contact support',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _supportTile({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AgrisellColors.searchBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Row(
        children: [
          Icon(icon, color: AgrisellColors.forestGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AgrisellColors.headingGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(
                    color: AgrisellColors.mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  String _safeErrorMessage(Object error, {required bool verifying}) =>
      error is AuthRegistrationException
          ? error.message
          : verifying
              ? 'We could not verify the OTP. Please try again.'
              : 'We could not resend the OTP. Please try again.';
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({
    required this.isResending,
    required this.cooldownSeconds,
    required this.accentColor,
    required this.onPressed,
  });

  final bool isResending;
  final int cooldownSeconds;
  final Color accentColor;
  final VoidCallback? onPressed;

  String _clockText(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isResending;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isEnabled
                ? AgrisellColors.forestSoft.withValues(alpha: 0.6)
                : AgrisellColors.searchBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled
                  ? accentColor.withValues(alpha: 0.3)
                  : AgrisellColors.borderLine,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isResending)
                SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: accentColor,
                  ),
                )
              else
                Icon(
                  Icons.sync_rounded,
                  size: 14,
                  color: isEnabled ? accentColor : AgrisellColors.mutedText,
                ),
              const SizedBox(width: 5),
              Text(
                cooldownSeconds == 0
                    ? 'Resend code'
                    : 'Resend in ${_clockText(cooldownSeconds)}',
                style: TextStyle(
                  color: isEnabled ? accentColor : AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    final mid = (length / 2).ceil();
    final group1Indices = List.generate(mid, (i) => i);
    final group2Indices = List.generate(length - mid, (i) => mid + i);

    return Semantics(
      label: '$length digit verification code',
      textField: true,
      child: GestureDetector(
        onTap: focusNode.requestFocus,
        child: SizedBox(
          height: 54,
          child: Stack(
            children: [
              Row(
                children: [
                  _buildCodeGroup(
                    indices: group1Indices,
                    code: code,
                    isFocused: focusNode.hasFocus,
                    hasError: hasError,
                    accentColor: accentColor,
                  ),
                  if (group2Indices.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '—',
                        style: TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    _buildCodeGroup(
                      indices: group2Indices,
                      code: code,
                      isFocused: focusNode.hasFocus,
                      hasError: hasError,
                      accentColor: accentColor,
                    ),
                  ],
                ],
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

  Widget _buildCodeGroup({
    required List<int> indices,
    required String code,
    required bool isFocused,
    required bool hasError,
    required Color accentColor,
  }) {
    final hasCurrentInGroup = indices.contains(code.length) && isFocused;
    final borderColor = hasError
        ? AgrisellColors.statusRedText
        : hasCurrentInGroup
            ? accentColor
            : AgrisellColors.borderLine;

    return Expanded(
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAF9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: hasCurrentInGroup ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            for (int i = 0; i < indices.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  height: double.infinity,
                  color: AgrisellColors.borderLine,
                ),
              Expanded(
                child: _buildDigitCell(
                  digit: indices[i] < code.length ? code[indices[i]] : '',
                  isCurrent: indices[i] == code.length && isFocused,
                  accentColor: accentColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDigitCell({
    required String digit,
    required bool isCurrent,
    required Color accentColor,
  }) {
    return Center(
      child: isCurrent && digit.isEmpty
          ? Container(
              width: 2,
              height: 22,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(1),
              ),
            )
          : Text(
              digit,
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
