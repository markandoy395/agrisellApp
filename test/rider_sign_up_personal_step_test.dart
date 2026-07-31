import 'package:agresell_app/core/theme/agrisellTheme.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_sign_up_validator.dart';
import 'package:agresell_app/features/rider/profile/presentation/controllers/rider_sign_up_controller.dart';
import 'package:agresell_app/features/rider/profile/presentation/widgets/rider_sign_up_personal_step.dart';
import 'package:agresell_app/features/shared/widgets/profile/phone_number_sync_control.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Rider personal step uses gender buttons and phone sync', (
    tester,
  ) async {
    final controller = RiderSignUpController();

    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(body: RiderSignUpPersonalStep(controller: controller)),
      ),
    );

    expect(find.byKey(const ValueKey('rider-gender-male')), findsOneWidget);
    expect(find.byKey(const ValueKey('rider-gender-female')), findsOneWidget);
    expect(find.byType(PhoneNumberSyncControl), findsOneWidget);
    expect(find.text('Phone number (09XXXXXXXXX)'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('rider-gender-female')));
    await tester.pump();

    expect(controller.draft.value(RiderSignUpFields.gender), 'Female');
    controller.dispose();
  });
}
