import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/safety/data/safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';

void main() {
  testWidgets(
    'app safety sheet renders all actions and opens confirm SOS dialog',
    (tester) async {
      final repository = InMemorySafetyIncidentRepository();
      final controller = SafetyIncidentController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAppSafetySheet(
                  context: context,
                  role: 'farmer',
                  controller: controller,
                ),
                child: const Text('Open Safety Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Safety Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Safety & Emergency Support'), findsOneWidget);
      expect(find.text('Emergency SOS'), findsOneWidget);
      expect(find.text('Report a Safety Issue / Incident'), findsOneWidget);
      expect(find.text('Incident History & Resolution Status'), findsOneWidget);
      expect(find.text('Contact Customer Support'), findsOneWidget);

      await tester.tap(find.text('Emergency SOS'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Emergency SOS'), findsOneWidget);
      expect(find.text('Yes, Send SOS Alert'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'app safety sheet report incident option opens report dialog',
    (tester) async {
      final repository = InMemorySafetyIncidentRepository();
      final controller = SafetyIncidentController(repository: repository);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => showAppSafetySheet(
                  context: context,
                  role: 'buyer',
                  controller: controller,
                ),
                child: const Text('Open Safety Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Safety Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Report a Safety Issue / Incident'));
      await tester.pumpAndSettle();

      expect(find.text('Report Safety Incident'), findsOneWidget);
      expect(find.text('Incident Category'), findsOneWidget);
      expect(find.text('Describe the Incident'), findsOneWidget);
      expect(find.text('Submit Report'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );
}
