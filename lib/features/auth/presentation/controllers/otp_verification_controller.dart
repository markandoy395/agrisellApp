import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';

/// Owns OTP input, request state, attempt limits, and the resend countdown.
class OtpVerificationController extends ChangeNotifier {
  OtpVerificationController(Duration resendCooldown) {
    focusNode.addListener(notifyListeners);
    _startCooldown(resendCooldown);
  }

  final code = TextEditingController();
  final focusNode = FocusNode();
  Timer? _timer;
  bool _disposed = false;
  int _incorrectAttempts = 0;
  int secondsRemaining = 0;
  bool isVerifying = false;
  bool isResending = false;
  String? error;
  String? status;

  bool attemptsExhausted(int maximum) => _incorrectAttempts >= maximum;

  void clearFeedback() {
    error = null;
    status = null;
    notifyListeners();
  }

  Future<bool> verify({
    required int codeLength,
    required int maxIncorrectAttempts,
    required Future<void> Function(String) onVerify,
  }) async {
    if (_disposed ||
        isVerifying ||
        isResending ||
        attemptsExhausted(maxIncorrectAttempts)) {
      return false;
    }
    final value = code.text.trim();
    if (value.length != codeLength) {
      error = 'Enter the $codeLength-digit code.';
      notifyListeners();
      return false;
    }
    isVerifying = true;
    clearFeedback();
    try {
      await onVerify(value);
      return !_disposed;
    } catch (failure) {
      if (_disposed) return false;
      if (failure is AuthOtpException) {
        if (failure.reason == AuthOtpFailureReason.invalid ||
            failure.reason == AuthOtpFailureReason.expired) {
          _incorrectAttempts++;
        } else if (failure.reason == AuthOtpFailureReason.tooManyAttempts) {
          _incorrectAttempts = maxIncorrectAttempts;
        }
      }
      error = attemptsExhausted(maxIncorrectAttempts)
          ? 'Too many incorrect attempts. Request a new OTP to continue.'
          : _safeErrorMessage(failure, verifying: true);
      return false;
    } finally {
      if (!_disposed) {
        isVerifying = false;
        notifyListeners();
      }
    }
  }

  Future<void> resend(
    Future<void> Function() onResend,
    Duration cooldown,
  ) async {
    isResending = true;
    notifyListeners();
    try {
      await onResend();
      if (_disposed) return;
      code.clear();
      _startCooldown(cooldown);
      _incorrectAttempts = 0;
      error = null;
      status = 'A new OTP was sent to your email.';
    } catch (failure) {
      if (_disposed) return;
      if (failure is AuthOtpException &&
          failure.reason == AuthOtpFailureReason.tooManyAttempts) {
        _startCooldown(cooldown);
      }
      status = null;
      error = _safeErrorMessage(failure, verifying: false);
    } finally {
      if (!_disposed) {
        isResending = false;
        notifyListeners();
      }
    }
  }

  void _startCooldown(Duration cooldown) {
    _timer?.cancel();
    secondsRemaining = cooldown.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining <= 1) {
        timer.cancel();
        secondsRemaining = 0;
      } else {
        secondsRemaining--;
      }
      notifyListeners();
    });
  }

  String _safeErrorMessage(Object failure, {required bool verifying}) =>
      failure is AuthRegistrationException
      ? failure.message
      : verifying
      ? 'We could not verify the OTP. Please try again.'
      : 'We could not resend the OTP. Please try again.';

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    focusNode.removeListener(notifyListeners);
    code.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
