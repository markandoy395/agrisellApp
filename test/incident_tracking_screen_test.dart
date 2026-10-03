import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/core/theme/agrisell_theme.dart';
import 'package:agresell_app/features/shared/safety/data/safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/utils/incident_tracking_formatters.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_resolution_stepper.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_status_badge.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/incident_tracking_card.dart';

class TrackingRepository extends InMemorySafetyIncidentRepository {
  TrackingRepository({super.seed});
  int loadCount = 0;
  Completer<List<SafetyIncident>>? pending;

  @override
  Future<List<SafetyIncident>> getMyIncidents({String? status}) {
    loadCount++;
    return pending?.future ?? super.getMyIncidents(status: status);
  }
}

SafetyIncident incident(SafetyIncidentStatus status) => SafetyIncident(
  reportId: 'INC-${status.name}',
  category: SafetyIncidentCategory.emergencySos,
  description: 'Need assistance',
  status: status,
  reportedAt: DateTime.now(),
  orderId: 42,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final loader = FontLoader(AgrisellTheme.fontFamily);
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      loader.addFont(
        rootBundle.load('assets/fonts/Poppins/Poppins-$weight.ttf'),
      );
    }
    await loader.load();
  });

  test('relative time formatting preserves each threshold', () {
    final now = DateTime(2026, 10, 1, 12);
    final cases = {
      const Duration(seconds: 59): 'Just now',
      const Duration(minutes: 1): '1m ago',
      const Duration(minutes: 59): '59m ago',
      const Duration(hours: 1): '1h ago',
      const Duration(hours: 23): '23h ago',
      const Duration(days: 1): '1d ago',
      const Duration(days: 6): '6d ago',
      const Duration(days: 7): '9/24/2026',
    };
    for (final entry in cases.entries) {
      expect(
        formatIncidentTimeAgo(now.subtract(entry.key), now: now),
        entry.value,
      );
    }
    expect(
      formatIncidentDateTime(DateTime(2026, 10, 1, 9, 5)),
      '10/1/2026 09:05',
    );
  });

  for (final status in SafetyIncidentStatus.values) {
    testWidgets('card preserves ${status.name} badges and resolution stages', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: Scaffold(
            body: IncidentTrackingCard(incident: incident(status)),
          ),
        ),
      );
      expect(find.text('ID: INC-${status.name}'), findsOneWidget);
      expect(find.text('Order #42'), findsOneWidget);
      expect(find.text('Need assistance'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(IncidentStatusBadge),
          matching: find.text(status.label),
        ),
        findsOneWidget,
      );
      final timeline = find.byType(IncidentResolutionStepper);
      final completed = status == SafetyIncidentStatus.resolved
          ? 3
          : status.isTerminal
          ? 2
          : 1;
      expect(
        find.descendant(
          of: timeline,
          matching: find.byIcon(Icons.check_circle_rounded),
        ),
        findsNWidgets(completed),
      );
      expect(
        find.text('Escalated'),
        status == SafetyIncidentStatus.escalated
            ? findsNWidgets(2)
            : findsNothing,
      );
      expect(
        find.descendant(
          of: timeline,
          matching: find.byIcon(Icons.cancel_rounded),
        ),
        status == SafetyIncidentStatus.rejected ? findsOneWidget : findsNothing,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('resolved audit retains author, note, and timestamp', (
    tester,
  ) async {
    final resolved = incident(SafetyIncidentStatus.resolved).copyWith(
      resolutionNotes: 'Confirmed safe',
      resolvedBy: 'Admin',
      resolvedAt: DateTime(2026, 10, 1, 9, 5),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: Scaffold(body: IncidentTrackingCard(incident: resolved)),
      ),
    );
    expect(find.text('Confirmed safe'), findsOneWidget);
    expect(find.textContaining('by Admin'), findsOneWidget);
    expect(find.text('Resolved at 10/1/2026 09:05'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'screen loads, filters, refreshes, and retains injected controller',
    (tester) async {
      final repository = TrackingRepository(
        seed: [
          incident(SafetyIncidentStatus.submitted),
          incident(SafetyIncidentStatus.resolved),
        ],
      );
      final controller = SafetyIncidentController(repository: repository);
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: AgrisellTheme.light,
          home: IncidentTrackingScreen(role: 'farmer', controller: controller),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.loadCount, 1);
      await tester.tap(find.text('In Progress'));
      await tester.pumpAndSettle();
      expect(find.text('ID: INC-submitted'), findsOneWidget);
      expect(find.text('ID: INC-resolved'), findsNothing);
      await tester.tap(find.text('Resolved / Closed'));
      await tester.pumpAndSettle();
      expect(find.text('ID: INC-resolved'), findsOneWidget);
      expect(find.text('ID: INC-submitted'), findsNothing);
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();
      expect(repository.loadCount, 2);
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();
      expect(repository.loadCount, 3);
      await tester.pumpWidget(const SizedBox());
      controller.setFilter('all');
      expect(controller.filter, 'all');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('loading transitions to filter-specific empty state', (
    tester,
  ) async {
    final repository = TrackingRepository()
      ..pending = Completer<List<SafetyIncident>>();
    final controller = SafetyIncidentController(repository: repository);
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: AgrisellTheme.light,
        home: IncidentTrackingScreen(role: 'buyer', controller: controller),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.pending!.complete([]);
    await tester.pumpAndSettle();
    expect(
      find.text('You have not reported any safety incidents or SOS alerts.'),
      findsOneWidget,
    );
    await tester.tap(find.text('In Progress'));
    await tester.pumpAndSettle();
    expect(
      find.text('No reports found matching the selected filter.'),
      findsOneWidget,
    );
    expect(find.text('Submit Safety Report'), findsOneWidget);
    expect(find.text('New Report / SOS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
