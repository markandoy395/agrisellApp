import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:agresell_app/features/shared/safety/presentation/utils/app_safety_coordinator.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_report_dialog.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_report_category_card.dart';

void main() {
  for (final role in ['buyer', 'farmer', 'rider']) {
    testWidgets(
      '$role categories validate and return selected report on compact screen',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 700));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        IncidentReportInput? result;
        await tester.pumpWidget(
          MaterialApp(
            theme: AgrisellTheme.light,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showIncidentReportDialog(
                      context: context,
                      role: role,
                    );
                  },
                  child: const Text('Report'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Report'));
        await tester.pumpAndSettle();
        final categories = AppSafetyCoordinator.categoriesForRole(role);
        expect(
          find.byType(IncidentReportCategoryCard),
          findsNWidgets(categories.length),
        );
        expect(find.text('Select Incident Category'), findsOneWidget);
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();
        expect(result, isNull);
        expect(find.text('Please describe the incident.'), findsOneWidget);
        await tester.ensureVisible(find.text(categories[1].label));
        await tester.tap(find.text(categories[1].label));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<IncidentReportCategoryCard>(
                find.byWidgetPredicate(
                  (w) =>
                      w is IncidentReportCategoryCard &&
                      w.category == categories[1],
                ),
              )
              .selected,
          isTrue,
        );
        await tester.ensureVisible(find.byType(TextFormField));
        await tester.enterText(
          find.byType(TextFormField),
          '  Unsafe situation at the pickup gate.  ',
        );
        await tester.tap(find.text('Submit Report'));
        await tester.pumpAndSettle();
        expect(result!.category, categories[1]);
        expect(result!.description, 'Unsafe situation at the pickup gate.');
        expect(find.text('Report Safety Incident'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('cancel dismisses without creating a report with keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 850);
    tester.view.devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
    });
    IncidentReportInput? result;
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showIncidentReportDialog(
                  context: context,
                  role: 'buyer',
                );
                completed = true;
              },
              child: const Text('Report'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Report'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Cancel')).bottom, lessThanOrEqualTo(570));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(completed, isTrue);
    expect(result, isNull);
    expect(tester.takeException(), isNull);
  });
}
