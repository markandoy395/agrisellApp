import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/auth/presentation/widgets/otp_verification_screen.dart';

void main() {
  testWidgets('late success after leaving OTP never pops the signup page', (
    tester,
  ) async {
    final response = Completer<void>();
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: key,
        home: const Scaffold(body: Text('Login entry')),
      ),
    );
    key.currentState!.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Signup credentials')),
      ),
    );
    await tester.pumpAndSettle();
    bool? result;
    final route = MaterialPageRoute<bool>(
      builder: (_) => OtpVerificationScreen(
        destination: 'buyer@example.com',
        onVerify: (_) => response.future,
      ),
    );
    unawaited(key.currentState!.push(route).then((value) => result = value));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Verify'));
    await tester.pump();
    key.currentState!.pop(false);
    // The OTP state is still mounted during its reverse transition.
    response.complete();
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text('Signup credentials'), findsOneWidget);
    expect(find.text('Login entry'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
