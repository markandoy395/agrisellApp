import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/shared/safety/data/safety_incident_repository.dart';
import 'package:agresell_app/features/shared/safety/domain/safety_incident.dart';

class SupabaseSafetyIncidentRepository implements SafetyIncidentRepository {
  SupabaseSafetyIncidentRepository({SupabaseClient? client})
      : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  @override
  Future<SafetyIncident> submitIncident({
    required String reportId,
    required SafetyIncidentCategory category,
    required String description,
    required String reporterRole,
    String? reporterName,
    String? reporterContact,
    String? reporterEmail,
    int? orderId,
    int? deliveryId,
    String? stage,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    List<String> attachments = const [],
    List<String> requestedActions = const [],
    String reportType = 'safety_report',
  }) async {
    try {
      // Try the RPC first
      final result = await _client.rpc('submit_safety_incident', params: {
        'p_report_id': reportId,
        'p_report_type': reportType,
        'p_category': category.name,
        'p_description': description,
        'p_reporter_role': reporterRole,
        'p_reporter_name': reporterName,
        'p_reporter_contact': reporterContact,
        'p_reporter_email': reporterEmail,
        'p_order_id': orderId,
        'p_delivery_id': deliveryId,
        'p_stage': stage,
        'p_latitude': latitude,
        'p_longitude': longitude,
        'p_accuracy_meters': accuracyMeters,
        'p_attachments': attachments,
        'p_requested_actions': requestedActions,
      });

      if (result is Map) {
        return SafetyIncident.fromJson(
          Map<String, Object?>.from(result),
        );
      }
    } on PostgrestException catch (_) {
      // Fallback: direct insert to rider_incidents table if RPC not yet deployed
      final values = <String, Object?>{
        'report_id': reportId,
        'report_type': reportType,
        'category': category.name,
        'description': description,
        'reporter_role': reporterRole,
        if (reporterName != null) 'reporter_name': reporterName,
        if (reporterContact != null) 'reporter_contact': reporterContact,
        if (reporterEmail != null) 'reporter_email': reporterEmail,
        if (orderId != null) 'order_id': orderId,
        if (deliveryId != null) 'delivery_id': deliveryId,
        if (stage != null) 'stage': stage,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (accuracyMeters != null) 'accuracy_meters': accuracyMeters,
        'attachments': attachments,
        'requested_actions': requestedActions,
        'status': 'submitted',
        'reported_at': DateTime.now().toUtc().toIso8601String(),
        if (_client.auth.currentUser?.id != null)
          'reporter_auth_id': _client.auth.currentUser!.id,
      };

      final row = await _client
          .from('rider_incidents')
          .insert(values)
          .select()
          .single();

      return SafetyIncident.fromJson(Map<String, Object?>.from(row));
    }

    return SafetyIncident(
      reportId: reportId,
      category: category,
      description: description,
      status: SafetyIncidentStatus.submitted,
      reportedAt: DateTime.now(),
      reportType: reportType,
      reporterRole: reporterRole,
      reporterName: reporterName,
      reporterContact: reporterContact,
      reporterEmail: reporterEmail,
      orderId: orderId,
      deliveryId: deliveryId,
      stage: stage,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      attachments: attachments,
      requestedActions: requestedActions,
    );
  }

  @override
  Future<List<SafetyIncident>> getMyIncidents({String? status}) async {
    try {
      final result = await _client.rpc('get_my_safety_incidents', params: {
        if (status != null && status != 'all') 'p_status': status,
      });

      if (result is List) {
        return result
            .map((item) => SafetyIncident.fromJson(
                  Map<String, Object?>.from(item as Map),
                ))
            .toList();
      }
    } on PostgrestException catch (_) {
      // Fallback: direct query
      var query = _client.from('rider_incidents').select();
      final currentUserId = _client.auth.currentUser?.id;
      if (currentUserId != null) {
        query = query.or('reporter_auth_id.eq.$currentUserId');
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        if (status == 'open') {
          query = query.inFilter(
            'status',
            ['submitted', 'underReview', 'waitingForInformation', 'escalated'],
          );
        } else if (status == 'resolved') {
          query = query.inFilter('status', ['resolved', 'rejected']);
        } else {
          query = query.eq('status', status);
        }
      }

      final rows = await query.order('reported_at', ascending: false);
      return (rows as List)
          .map((item) => SafetyIncident.fromJson(
                Map<String, Object?>.from(item as Map),
              ))
          .toList();
    }
    return const [];
  }
}
