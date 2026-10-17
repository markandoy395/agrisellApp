import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/auth/data/auth_registration_exception.dart';
import 'package:agresell_app/features/auth/presentation/controllers/otp_verification_controller.dart';

void main() {
  late OtpVerificationController controller;

  setUp(() {
    controller = OtpVerificationController(Duration.zero);
  });
  tearDown(() => controller.dispose());

  test(
    'concurrent verification sends one request and completes once',
    () async {
      final response = Completer<void>();
      var requests = 0;
      controller.code.text = '123456';
      Future<void> verify(String _) {
        requests++;
        return response.future;
      }

      final first = controller.verify(
        codeLength: 6,
        maxIncorrectAttempts: 5,
        onVerify: verify,
      );
      final second = controller.verify(
        codeLength: 6,
        maxIncorrectAttempts: 5,
        onVerify: verify,
      );
      response.complete();
      expect(await first, isTrue);
      expect(await second, isFalse);
      expect(requests, 1);
    },
  );

  test('validates the configured length before calling verification', () async {
    var called = false;
    controller.code.text = '123';
    expect(
      await controller.verify(
        codeLength: 4,
        maxIncorrectAttempts: 5,
        onVerify: (_) async => called = true,
      ),
      isFalse,
    );
    expect(called, isFalse);
    expect(controller.error, 'Enter the 4-digit code.');

    controller.code.text = '1234';
    expect(
      await controller.verify(
        codeLength: 4,
        maxIncorrectAttempts: 5,
        onVerify: (code) async {
          expect(code, '1234');
          expect(controller.isVerifying, isTrue);
        },
      ),
      isTrue,
    );
    expect(controller.isVerifying, isFalse);
    expect(controller.error, isNull);
  });

  test('unexpected errors are safe and do not consume attempts', () async {
    controller.code.text = '123456';
    await controller.verify(
      codeLength: 6,
      maxIncorrectAttempts: 1,
      onVerify: (_) async => throw StateError('private details'),
    );
    expect(controller.attemptsExhausted(1), isFalse);
    expect(controller.error, 'We could not verify the OTP. Please try again.');
  });

  test(
    'expired codes consume attempts and server lockout exhausts them',
    () async {
      controller.code.text = '123456';
      for (final reason in [
        AuthOtpFailureReason.expired,
        AuthOtpFailureReason.tooManyAttempts,
      ]) {
        await controller.verify(
          codeLength: 6,
          maxIncorrectAttempts: 5,
          onVerify: (_) async =>
              throw AuthOtpException('Try again', reason: reason),
        );
        expect(
          controller.attemptsExhausted(5),
          reason == AuthOtpFailureReason.tooManyAttempts,
        );
      }
      expect(
        controller.error,
        'Too many incorrect attempts. Request a new OTP to continue.',
      );
    },
  );

  testWidgets('cooldown ticks down and resend resets input and feedback', (
    tester,
  ) async {
    controller.dispose();
    controller = OtpVerificationController(const Duration(seconds: 2));
    expect(controller.secondsRemaining, 2);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.secondsRemaining, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(controller.secondsRemaining, 0);

    controller.code.text = '123456';
    await controller.resend(() async {}, const Duration(seconds: 3));
    expect(controller.code.text, isEmpty);
    expect(controller.secondsRemaining, 3);
    expect(controller.status, 'A new OTP was sent to your email.');
    controller.clearFeedback();
    expect(controller.status, isNull);
    expect(controller.error, isNull);
    await tester.pump(const Duration(seconds: 3));
    expect(controller.secondsRemaining, 0);
  });

  test('rate-limited resend restarts cooldown and keeps input', () async {
    controller.code.text = '123456';
    await controller.resend(
      () async => throw const AuthOtpException(
        'Please wait before resending.',
        reason: AuthOtpFailureReason.tooManyAttempts,
      ),
      const Duration(seconds: 60),
    );
    expect(controller.secondsRemaining, 60);
    expect(controller.code.text, '123456');
    expect(controller.error, 'Please wait before resending.');
    expect(controller.status, isNull);
    expect(controller.isResending, isFalse);
  });

  test('pending requests can complete after disposal', () async {
    final disposedController = OtpVerificationController(Duration.zero);
    disposedController.code.text = '123456';
    final verification = Completer<void>();
    final resend = Completer<void>();
    final verifying = disposedController.verify(
      codeLength: 6,
      maxIncorrectAttempts: 5,
      onVerify: (_) => verification.future,
    );
    final resending = disposedController.resend(
      () => resend.future,
      const Duration(seconds: 60),
    );
    disposedController.dispose();
    verification.complete();
    resend.complete();
    expect(await verifying, isFalse);
    await resending;
  });
}
