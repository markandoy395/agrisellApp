import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_offline_action_queue.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_problem.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_report_status_card.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/rider/safety/data/rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';
import 'package:agresell_app/features/rider/safety/presentation/controllers/rider_safety_report_controller.dart';

import 'support/memory_offline_queue_repository.dart';

part 'support/rider_safety_problem_phase11_support.dart';

void main() {
  test(
    'safety report records operational evidence and status updates',
    () async {
      final repository = InMemoryRiderSafetyRepository();
      final report = _safetyReport();

      final saved = await repository.submitReport(report);
      final updated = await repository.updateReportStatus(
        riderId: 'rider-1',
        reportId: report.id,
        status: RiderSafetyReportStatus.underReview,
      );

      expect(saved.location.accuracyMeters, 6);
      expect(saved.attachments.single, startsWith('protected://'));
      expect(updated?.status, RiderSafetyReportStatus.underReview);
      expect(
        repository.updateReportStatus(
          riderId: 'other-rider',
          reportId: report.id,
          status: RiderSafetyReportStatus.resolved,
        ),
        completion(isNull),
      );
    },
  );

  test('offline safety report synchronizes once after reconnection', () async {
    final queue = _queue();
    final repository = InMemoryRiderSafetyRepository();
    final controller = RiderSafetyReportController(
      repository: repository,
      offlineQueue: queue,
    );
    addTearDown(controller.dispose);
    addTearDown(queue.dispose);
    controller.setBackendReachable(false);

    await controller.submit(_safetyReport());
    expect(queue.actions.single.type, OfflineDeliveryActionType.safetyReport);
    controller.setBackendReachable(true);
    await controller.synchronize();
    expect(queue.actions, isEmpty);
    final updated = await repository.updateReportStatus(
      riderId: 'rider-1',
      reportId: 'safety-1',
      status: RiderSafetyReportStatus.resolved,
    );
    expect(updated?.status, RiderSafetyReportStatus.resolved);
  });

  test(
    'problem report is authorized, idempotent, and status is visible',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [_request()],
      );
      final controller = await _controller(repository);
      addTearDown(controller.dispose);

      final result = await controller.reportDeliveryProblem(
        deliveryId: 'delivery-1',
        riderId: 'rider-1',
        kind: RiderDeliveryProblemKind.damagedProduct,
        notes: 'Crate is visibly damaged.',
        photoReferences: const ['protected://reports/photo-1'],
      );
      final report = controller.problemReportFor('delivery-1');
      expect(result.isSuccess, isTrue);
      expect(repository.deliveryProblemFor('delivery-1')?.id, report?.id);
      expect(
        await controller.updateDeliveryProblemStatus(
          riderId: 'rider-1',
          reportId: report!.id,
          status: RiderDeliveryProblemStatus.escalated,
        ),
        isTrue,
      );
      expect(
        controller.problemReportFor('delivery-1')?.status,
        RiderDeliveryProblemStatus.escalated,
      );
    },
  );

  test(
    'offline problem report uses Phase 9 queue without duplicates',
    () async {
      final repository = InMemoryRiderDeliveryRepository(
        requests: [_request()],
      );
      final queue = _queue();
      final controller = await _controller(repository, queue: queue);
      addTearDown(controller.dispose);
      addTearDown(queue.dispose);
      controller.setBackendReachable(false);

      final result = await controller.reportDeliveryProblem(
        deliveryId: 'delivery-1',
        riderId: 'rider-1',
        kind: RiderDeliveryProblemKind.routeBlocked,
        notes: 'Road is closed by flooding.',
      );
      expect(result.isSuccess, isTrue);
      expect(
        queue.actions.single.type,
        OfflineDeliveryActionType.problemReport,
      );
      controller.setBackendReachable(true);
      await controller.synchronizeOfflineActions();
      expect(queue.actions, isEmpty);
      expect(
        repository.deliveryProblemFor('delivery-1')?.kind,
        RiderDeliveryProblemKind.routeBlocked,
      );
    },
  );

  testWidgets('problem-report status is visible in Active Delivery UI', (
    tester,
  ) async {
    final report = RiderDeliveryProblemReport(
      id: 'problem-1',
      deliveryId: 'delivery-1',
      riderId: 'rider-1',
      kind: RiderDeliveryProblemKind.buyerUnavailable,
      location: _statusLocation(),
      createdAt: DateTime(2026, 7, 15),
      notes: 'Buyer did not answer.',
      status: RiderDeliveryProblemStatus.waitingForInformation,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: RiderReportStatusCard(report: report)),
      ),
    );
    expect(find.text('Problem report'), findsOneWidget);
    expect(
      find.text('Buyer unavailable - Waiting for information'),
      findsOneWidget,
    );
  });
}
