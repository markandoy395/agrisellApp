import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';

class FarmerInformationRequestTestDriver {
  bool? returnedResult;

  Future<void> openScreen(
    WidgetTester tester,
    FarmerVerificationRepository repository, {
    FarmerVerificationDetails details = const FarmerVerificationDetails(),
  }) async {
    returnedResult = null;
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                returnedResult = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (_) => FarmerInformationRequestScreen(
                      details: details,
                      repository: repository,
                    ),
                  ),
                );
              },
              child: const Text('Open corrections'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open corrections'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, int index, String value) async {
    final field = find.byType(TextField).at(index);
    await tester.ensureVisible(field);
    await tester.enterText(field, value);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Submit Corrections'));
    await tester.tap(find.text('Submit Corrections'));
  }
}
