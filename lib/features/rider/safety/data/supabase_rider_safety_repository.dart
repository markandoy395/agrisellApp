import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_rider_evidence_uploader.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/safety/data/rider_safety_repository.dart';
import 'package:agresell_app/features/rider/safety/data/supabase_rider_incident_store.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_action.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';

class SupabaseRiderSafetyRepository implements RiderSafetyRepository {
  SupabaseRiderSafetyRepository({SupabaseClient? client})
    : _store = SupabaseRiderIncidentStore(client: client),
      _evidence = SupabaseRiderEvidenceUploader(
        SupabaseDeliveryDataSource(client ?? AgrisellSupabase.client),
      );

  final SupabaseRiderIncidentStore _store;
  final SupabaseRiderEvidenceUploader _evidence;

  @override
  Future<void> submit(RiderSafetyAction action) => _store.submit(
    reportId: action.id,
    riderId: action.riderId,
    reportType: 'safety_action',
    category: action.type.name,
    description: action.reason ?? action.type.label,
    reportedAt: action.createdAt,
  );

  @override
  Future<RiderSafetyReport> submitReport(RiderSafetyReport report) async {
    final attachments = await _evidence.resolveAll(
      references: report.attachments,
      deliveryId: report.deliveryId,
      stage: DeliveryProofStage.delivery,
      type: DeliveryProofType.deliveryPhoto,
    );
    final row = await _store.submit(
      reportId: report.id,
      riderId: report.riderId,
      deliveryId: report.deliveryId,
      reportType: 'safety_report',
      category: report.category.name,
      stage: report.stage.name,
      description: report.description,
      latitude: report.location.latitude,
      longitude: report.location.longitude,
      accuracyMeters: report.location.accuracyMeters,
      attachments: attachments,
      requestedActions: report.requestedActions
          .map((action) => action.name)
          .toList(growable: false),
      reportedAt: report.createdAt,
    );
    for (final reference in report.attachments) {
      await _evidence.removeLocal(reference);
    }
    return _report(row);
  }

  @override
  Future<RiderSafetyReport?> updateReportStatus({
    required String riderId,
    required String reportId,
    required RiderSafetyReportStatus status,
  }) async {
    final row = await _store.updateStatus(
      reportId: reportId,
      riderId: riderId,
      status: status.name,
    );
    return row == null ? null : _report(row);
  }

  RiderSafetyReport _report(Map<String, Object?> row) {
    final actions = (row['requested_actions'] as List? ?? const [])
        .map((value) => RiderSafetyResponseAction.values.byName('$value'))
        .toSet();
    return RiderSafetyReport(
      id: '${row['report_id']}',
      deliveryId: '${row['delivery_id']}',
      riderId: '${row['rider_id']}',
      stage: DeliveryStatus.values.byName('${row['stage']}'),
      location: DeliveryStatusLocation(
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
        accuracyMeters: (row['accuracy_meters'] as num).toDouble(),
        timestamp: DateTime.parse('${row['reported_at']}'),
      ),
      createdAt: DateTime.parse('${row['reported_at']}'),
      category: RiderSafetyCategory.values.byName('${row['category']}'),
      description: '${row['description']}',
      attachments: (row['attachments'] as List? ?? const []).cast<String>(),
      requestedActions: actions,
      status: RiderSafetyReportStatus.values.byName('${row['status']}'),
    );
  }
}
