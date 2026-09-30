import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/shared/safety/data/safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';
import 'package:agresell_app/features/shared/safety/presentation/controllers/safety_incident_controller.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';

void main() {
  group('All Roles Safety Incidents Contract & Domain Tests', () {
    const migrationName =
        '20260919193000_expand_safety_incidents_for_all_roles.sql';

    final appMigration = File('supabase/migrations/$migrationName');
    final adminMigration = File(
      '../agrisellDashboard/agrisellAdmin/supabase/migrations/$migrationName',
    );

    test('multi-role safety migration exists in both app and admin dashboard', () {
      expect(
        appMigration.existsSync(),
        isTrue,
        reason: 'Missing in agresellApp/supabase/migrations',
      );
      expect(
        adminMigration.existsSync(),
        isTrue,
        reason:
            'Missing in agrisellDashboard/agrisellAdmin/supabase/migrations',
      );
    });

    test('multi-role safety migration contents are synchronized', () {
      expect(
        appMigration.readAsStringSync(),
        adminMigration.readAsStringSync(),
      );
    });

    test('migration defines schema updates and multi-role safety RPCs', () {
      final sql = appMigration.readAsStringSync();

      expect(sql, contains('alter table public.rider_incidents'));
      expect(sql, contains('alter column rider_id drop not null'));
      expect(sql, contains('add column if not exists reporter_role text'));
      expect(sql, contains('add column if not exists reporter_auth_id uuid'));
      expect(sql, contains('add column if not exists order_id bigint'));
      expect(sql, contains('function private.admin_safety_incidents('));
      expect(sql, contains('function private.admin_resolve_safety_incident('));
      expect(sql, contains('function public.submit_safety_incident('));
      expect(sql, contains('function public.get_my_safety_incidents('));
      expect(
        sql,
        contains('grant execute on function public.submit_safety_incident('),
      );
      expect(
        sql,
        contains('grant execute on function public.get_my_safety_incidents('),
      );
    });

    test('SafetyIncident serialization and copyWith work correctly', () {
      final now = DateTime.now();
      final incident = SafetyIncident(
        reportId: 'INC-1001',
        category: SafetyIncidentCategory.emergencySos,
        description: 'Need urgent help',
        status: SafetyIncidentStatus.submitted,
        reportedAt: now,
        reporterRole: 'buyer',
        reporterName: 'John Buyer',
        reporterContact: '09123456789',
        reporterEmail: 'buyer@example.com',
        orderId: 456,
      );

      expect(incident.isEmergency, isTrue);
      expect(incident.status.isOpen, isTrue);

      final json = incident.toJson();
      expect(json['report_id'], 'INC-1001');
      expect(json['category'], 'emergencySos');
      expect(json['reporter_role'], 'buyer');
      expect(json['order_id'], 456);

      final deserialized = SafetyIncident.fromJson(json);
      expect(deserialized.reportId, incident.reportId);
      expect(deserialized.category, incident.category);
      expect(deserialized.reporterRole, incident.reporterRole);
      expect(deserialized.orderId, 456);

      final updated = deserialized.copyWith(
        status: SafetyIncidentStatus.resolved,
        resolutionNotes: 'Dispatched help and confirmed safe',
        resolvedBy: 'Admin Dispatch',
      );
      expect(updated.status, SafetyIncidentStatus.resolved);
      expect(updated.status.isTerminal, isTrue);
      expect(updated.resolutionNotes, 'Dispatched help and confirmed safe');
      expect(updated.resolvedBy, 'Admin Dispatch');
    });

    test('SafetyIncidentController supports SOS, reports, and filtering across roles', () async {
      final repository = InMemorySafetyIncidentRepository();
      final controller = SafetyIncidentController(repository: repository);

      expect(controller.incidents, isEmpty);

      // 1. Submit Buyer SOS
      final buyerSos = await controller.submitSOS(
        reporterRole: 'buyer',
        reporterName: 'Alice Buyer',
        reporterContact: '09991112233',
        orderId: 101,
      );
      expect(buyerSos, isNotNull);
      expect(buyerSos!.category, SafetyIncidentCategory.emergencySos);
      expect(buyerSos.reporterRole, 'buyer');
      expect(buyerSos.isEmergency, isTrue);

      // 2. Submit Farmer Incident Report
      final farmerReport = await controller.submitIncident(
        category: SafetyIncidentCategory.theft,
        description: 'Crops damaged and harvested without authorization',
        reporterRole: 'farmer',
        reporterName: 'Farmer Bob',
        reporterContact: '09887776655',
      );
      expect(farmerReport, isNotNull);
      expect(farmerReport!.category, SafetyIncidentCategory.theft);
      expect(farmerReport.reporterRole, 'farmer');

      // 3. Submit Rider Incident Report
      final riderReport = await controller.submitIncident(
        category: SafetyIncidentCategory.vehicleBreakdown,
        description: 'Flat tire near highway junction',
        reporterRole: 'rider',
        reporterName: 'Rider Charlie',
        reporterContact: '09776665544',
        deliveryId: 505,
      );
      expect(riderReport, isNotNull);
      expect(riderReport!.category, SafetyIncidentCategory.vehicleBreakdown);
      expect(riderReport.reporterRole, 'rider');

      // Controller should have all 3 incidents
      expect(controller.incidents.length, 3);
      expect(controller.filteredIncidents.length, 3);

      // Test Filter
      controller.setFilter('open');
      expect(controller.filteredIncidents.length, 3);

      controller.setFilter('resolved');
      expect(controller.filteredIncidents.length, 0);

      controller.setFilter('all');
      expect(controller.filteredIncidents.length, 3);
    });

    testWidgets(
      'IncidentTrackingScreen renders filter chips without overflow on narrow width',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final repository = InMemorySafetyIncidentRepository();
        final controller = SafetyIncidentController(repository: repository);

        await tester.pumpWidget(
          MaterialApp(
            home: IncidentTrackingScreen(
              role: 'farmer',
              controller: controller,
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Incident Tracking'), findsOneWidget);
        expect(find.text('All Reports'), findsOneWidget);
        expect(find.text('In Progress'), findsOneWidget);
        expect(find.text('Resolved / Closed'), findsOneWidget);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('In Progress'));
        await tester.pump();
        expect(controller.filter, 'open');
        expect(tester.takeException(), isNull);
      },
    );
  });
}
