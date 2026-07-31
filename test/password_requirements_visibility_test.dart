import 'package:agresell_app/features/auth/presentation/widgets/auth_password_requirements.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_security_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared checklist disappears when all password rules pass', (
    tester,
  ) async {
    final password = TextEditingController();
    addTearDown(password.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TextField(controller: password),
              AuthPasswordRequirements(controller: password),
            ],
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'weak');
    await tester.pump();
    expect(find.text('Password requirements'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Strong123!');
    await tester.pump();
    expect(find.text('Password requirements'), findsNothing);
  });

  testWidgets('rider signup checklist disappears for a strong password', (
    tester,
  ) async {
    final controller = RiderSignUpController();
    addTearDown(controller.dispose);
    controller.updateSensitive(password: 'Strong123!');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RiderSignUpSecurityStep(controller: controller)),
      ),
    );

    expect(find.text('Password requirements'), findsNothing);
    expect(find.text('Password is too weak.'), findsNothing);
  });
}
