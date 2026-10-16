import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_resolution_audit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in [240.0, 320.0]) {
    for (final scale in [1.0, 2.0]) {
      for (final author in [
        null,
        'Alexandra Safety Resolution Administrator',
      ]) {
        testWidgets(
          'audit fits width $width, text scale $scale, author $author',
          (tester) async {
            const title = 'ADMIN RESOLUTION AUDIT NOTE';
            final incident = SafetyIncident(
              reportId: 'INC-1',
              category: SafetyIncidentCategory.emergencySos,
              description: 'Need assistance',
              status: SafetyIncidentStatus.resolved,
              reportedAt: DateTime(2026, 10, 1),
              resolutionNotes: 'Confirmed safe',
              resolvedBy: author,
              resolvedAt: DateTime(2026, 10, 1, 9, 5),
            );

            await tester.pumpWidget(
              MaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: Center(
                      child: SizedBox(
                        width: width,
                        child: MediaQuery(
                          data: MediaQueryData(
                            textScaler: TextScaler.linear(scale),
                          ),
                          child: IncidentResolutionAudit(incident: incident),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );

            expect(tester.takeException(), isNull);
            final heading = find.text(
              author == null ? title : '$title • by $author',
              findRichText: true,
            );
            expect(heading, findsOneWidget);
            final text = tester.widget<RichText>(heading);
            expect(text.maxLines, isNull);
            expect(text.softWrap, isTrue);
            final auditBounds = tester.getRect(
              find.byType(IncidentResolutionAudit),
            );
            final headingBounds = tester.getRect(heading);
            expect(headingBounds.left, greaterThanOrEqualTo(auditBounds.left));
            expect(headingBounds.right, lessThanOrEqualTo(auditBounds.right));
            expect(find.text('Confirmed safe'), findsOneWidget);
            expect(find.text('Resolved at 10/1/2026 09:05'), findsOneWidget);
          },
        );
      }
    }
  }
}
