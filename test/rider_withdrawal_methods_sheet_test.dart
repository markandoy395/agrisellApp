import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/controllers/rider_analytics_controller.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_withdrawal_methods_sheet.dart';

void main() {
  Future<RiderAnalyticsController> openSheet(
    WidgetTester tester,
    InMemoryRiderAnalyticsRepository repository,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final controller = RiderAnalyticsController(repository: repository);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: RiderWithdrawalMethodsSheet(
            riderId: 'rider-1',
            controller: controller,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return controller;
  }

  Future<void> tap(WidgetTester tester, String text) async {
    await tester.ensureVisible(find.text(text));
    await tester.tap(find.text(text));
    await tester.pumpAndSettle();
  }

  testWidgets('GCash validation, cancel retention, and successful save reset', (
    tester,
  ) async {
    final controller = await openSheet(
      tester,
      InMemoryRiderAnalyticsRepository(),
    );
    expect(
      find.textContaining('No withdrawal methods saved yet.'),
      findsOneWidget,
    );
    await tap(tester, 'Add Withdrawal Method');
    await tap(tester, 'Save Method');
    expect(find.text('Account name is required'), findsOneWidget);
    expect(find.text('GCash mobile number is required'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name on account'),
      '  Rider Name  ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '09XXXXXXXXX'),
      '12345',
    );
    await tap(tester, 'Save Method');
    expect(
      find.text('Enter a valid 11-digit GCash number (09XXXXXXXXX)'),
      findsOneWidget,
    );
    expect(controller.withdrawalMethods, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, '09XXXXXXXXX'),
      '0917 123 4567',
    );
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await tap(tester, 'Cancel');
    await tap(tester, 'Add Withdrawal Method');
    expect(find.text('  Rider Name  '), findsOneWidget);
    expect(find.text('0917 123 4567'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);

    await tap(tester, 'Save Method');
    final method = controller.withdrawalMethods.single;
    expect(method.accountName, 'Rider Name');
    expect(method.accountNumber, '0917 123 4567');
    expect(method.bankName, isEmpty);
    expect(method.isDefault, isFalse);
    expect(find.text('Rider Name · 0917 123 4567'), findsOneWidget);
    await tap(tester, 'Add Withdrawal Method');
    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(
      fields.map((field) => field.controller!.text),
      everyElement(isEmpty),
    );
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
  });

  testWidgets('save and delete failures preserve the form and saved methods', (
    tester,
  ) async {
    final controller = await openSheet(tester, _FailingWithdrawalRepository());
    await tap(tester, 'Add Withdrawal Method');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name on account'),
      'Unsaved Rider',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '09XXXXXXXXX'),
      '09171234567',
    );
    await tap(tester, 'Save Method');
    expect(
      find.textContaining('Failed to save withdrawal method:'),
      findsOneWidget,
    );
    expect(find.text('Unsaved Rider'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Save Method'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.pump(const Duration(seconds: 5));
    await tap(tester, 'Cancel');
    await tester.tap(find.byTooltip('Remove'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Failed to delete method:'), findsOneWidget);
    expect(controller.withdrawalMethods, hasLength(1));
    expect(find.text('Existing Rider · 09181234567'), findsOneWidget);
  });
}

class _FailingWithdrawalRepository extends InMemoryRiderAnalyticsRepository {
  _FailingWithdrawalRepository()
    : super(
        withdrawalMethodsByRider: {
          'rider-1': [
            const RiderWithdrawalMethod(
              methodId: 'existing-1',
              payoutMethod: 'gcash',
              accountName: 'Existing Rider',
              accountNumber: '09181234567',
            ),
          ],
        },
      );

  @override
  Future<RiderWithdrawalMethod> saveWithdrawalMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  }) async => throw StateError('Save rejected');

  @override
  Future<void> deleteWithdrawalMethod({
    required String riderId,
    required String methodId,
  }) async => throw StateError('Delete rejected');
}
