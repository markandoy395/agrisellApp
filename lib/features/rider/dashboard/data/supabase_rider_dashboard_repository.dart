import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_dashboard_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_dashboard_state.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_data_source.dart';

class SupabaseRiderDashboardRepository
    implements RiderDashboardRepository, RiderDataSourceMetadata {
  SupabaseRiderDashboardRepository({SupabaseClient? client})
    : _client = client ?? AgrisellSupabase.client;

  final SupabaseClient _client;

  @override
  RiderDataOrigin get dataOrigin => RiderDataOrigin.backend;

  @override
  Future<RiderDashboardData> fetchDashboard({required String riderId}) async {
    final value = await _client.rpc<Object?>('current_rider_dashboard');
    final row = _map(value);
    return RiderDashboardData(
      metrics: RiderDashboardMetrics(
        todayCompletedDeliveries:
            (row['today_completed_deliveries'] as num?)?.toInt() ?? 0,
        todayEstimatedEarnings:
            (row['today_estimated_earnings'] as num?)?.toDouble() ?? 0,
        unreadMessageCount: (row['unread_message_count'] as num?)?.toInt() ?? 0,
        unreadNotificationCount:
            (row['unread_notification_count'] as num?)?.toInt() ?? 0,
        cancelledOrFailedDeliveries:
            (row['cancelled_or_failed_deliveries'] as num?)?.toInt(),
        pendingEarnings: (row['pending_earnings'] as num?)?.toDouble(),
        averageRating: (row['average_rating'] as num?)?.toDouble(),
        completedDeliveryCount: (row['completed_delivery_count'] as num?)
            ?.toInt(),
        onTimeDeliveryRate: (row['on_time_delivery_rate'] as num?)?.toDouble(),
        cancellationRate: (row['cancellation_rate'] as num?)?.toDouble(),
      ),
      fetchedAt: DateTime.tryParse('${row['fetched_at']}') ?? DateTime.now(),
      dataOrigin: dataOrigin,
      unavailableSections: (row['unavailable_sections'] as List? ?? const [])
          .cast<String>(),
    );
  }
}

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};
