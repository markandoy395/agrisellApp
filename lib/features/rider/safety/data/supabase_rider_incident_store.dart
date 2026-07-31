import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';

class SupabaseRiderIncidentStore {
  SupabaseRiderIncidentStore({SupabaseClient? client})
    : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  Future<Map<String, Object?>> submit({
    required String reportId,
    required String riderId,
    required String reportType,
    required String category,
    required DateTime reportedAt,
    String? deliveryId,
    String? stage,
    String description = '',
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    List<String> attachments = const [],
    List<String> requestedActions = const [],
  }) async {
    final values = <String, Object?>{
      'report_id': reportId,
      'rider_id': riderId,
      'delivery_id': deliveryId,
      'report_type': reportType,
      'category': category,
      'stage': stage,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy_meters': accuracyMeters,
      'attachments': attachments,
      'requested_actions': requestedActions,
      'reported_at': reportedAt.toUtc().toIso8601String(),
    };
    try {
      final row = await _client
          .from('rider_incidents')
          .insert(values)
          .select()
          .single();
      return _map(row);
    } on PostgrestException catch (error) {
      if (error.code != '23505') rethrow;
      final row = await _client
          .from('rider_incidents')
          .select()
          .eq('report_id', reportId)
          .eq('rider_id', riderId)
          .single();
      return _map(row);
    }
  }

  Future<Map<String, Object?>?> load({
    required String reportId,
    required String riderId,
  }) async {
    final row = await _client
        .from('rider_incidents')
        .select()
        .eq('report_id', reportId)
        .eq('rider_id', riderId)
        .maybeSingle();
    return row == null ? null : _map(row);
  }

  Future<Map<String, Object?>?> updateStatus({
    required String reportId,
    required String riderId,
    required String status,
  }) async {
    final row = await _client
        .from('rider_incidents')
        .update({
          'status': status,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('report_id', reportId)
        .eq('rider_id', riderId)
        .select()
        .maybeSingle();
    return row == null ? null : _map(row);
  }
}

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};
