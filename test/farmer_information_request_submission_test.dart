import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';

import 'support/farmer_information_request_test_driver.dart';

void main() {
  late FarmerInformationRequestTestDriver driver;

  setUp(() => driver = FarmerInformationRequestTestDriver());

  testWidgets('missing names block submission without leaving the screen', (
    tester,
  ) async {
    var called = false;
    final repository = FarmerVerificationRepository(
      customResubmitHandler:
          ({
            firstName,
            lastName,
            phoneNumber,
            farmName,
            farmAddress,
            profileImageBytes,
            farmImageBytes,
            notes,
          }) async {
            called = true;
          },
    );
    await driver.openScreen(tester, repository);
    await driver.enter(tester, 0, '   ');
    await driver.submit(tester);
    await tester.pumpAndSettle();
    expect(find.text('First and last name are required.'), findsOneWidget);
    expect(called, isFalse);
    expect(driver.returnedResult, isNull);
    expect(find.byType(FarmerInformationRequestScreen), findsOneWidget);
  });

  testWidgets(
    'submission trims values, preserves optional nulls, and returns true',
    (tester) async {
      final completion = Completer<void>();
      final values = <String, Object?>{};
      final repository = FarmerVerificationRepository(
        customResubmitHandler:
            ({
              firstName,
              lastName,
              phoneNumber,
              farmName,
              farmAddress,
              profileImageBytes,
              farmImageBytes,
              notes,
            }) async {
              values.addAll({
                'firstName': firstName,
                'lastName': lastName,
                'phone': phoneNumber,
                'farmName': farmName,
                'farmAddress': farmAddress,
                'notes': notes,
                'profileImage': profileImageBytes,
                'farmImage': farmImageBytes,
              });
              await completion.future;
            },
      );
      await driver.openScreen(
        tester,
        repository,
        details: const FarmerVerificationDetails(
          firstName: ' Juan ',
          lastName: ' Dela Cruz ',
          phoneNumber: '   ',
          profileImageUrl: 'https://example.test/profile.jpg',
          farmImages: ['https://example.test/farm.jpg'],
        ),
      );
      expect(find.text('Tap to change'), findsNWidgets(2));
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsNWidgets(2));
      await driver.enter(tester, 5, '   ');
      await driver.submit(tester);
      await tester.pump();
      expect(values['firstName'], 'Juan');
      expect(values['lastName'], 'Dela Cruz');
      for (final key in [
        'phone',
        'farmName',
        'farmAddress',
        'notes',
        'profileImage',
        'farmImage',
      ]) {
        expect(values[key], isNull);
      }
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final button = find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byType(ElevatedButton),
      );
      expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
      completion.complete();
      await tester.pumpAndSettle();
      expect(driver.returnedResult, isTrue);
      expect(find.byType(FarmerInformationRequestScreen), findsNothing);
    },
  );

  testWidgets('failed submission retains edits and can be retried', (
    tester,
  ) async {
    var shouldFail = true;
    var attempts = 0;
    final repository = FarmerVerificationRepository(
      customResubmitHandler:
          ({
            firstName,
            lastName,
            phoneNumber,
            farmName,
            farmAddress,
            profileImageBytes,
            farmImageBytes,
            notes,
          }) async {
            attempts++;
            if (shouldFail) throw StateError('Submission rejected');
          },
    );
    await driver.openScreen(
      tester,
      repository,
      details: const FarmerVerificationDetails(
        firstName: 'Juan',
        lastName: 'Dela Cruz',
      ),
    );
    await driver.enter(tester, 3, 'Updated Farm');
    await driver.enter(tester, 5, 'My correction details');
    await driver.submit(tester);
    await tester.pumpAndSettle();
    expect(
      find.text('Failed to submit corrections. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Updated Farm'), findsOneWidget);
    expect(find.text('My correction details'), findsOneWidget);
    expect(driver.returnedResult, isNull);
    shouldFail = false;
    await driver.submit(tester);
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(driver.returnedResult, isTrue);
  });
}
