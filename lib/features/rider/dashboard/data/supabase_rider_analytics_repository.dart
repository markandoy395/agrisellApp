import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_delivery_analytics_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'supabase_rider_withdrawals.dart';
import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/data/supabase_delivery_data_source.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';

class SupabaseRiderAnalyticsRepository
    with SupabaseRiderWithdrawals
    implements RiderAnalyticsRepository {
  SupabaseRiderAnalyticsRepository({SupabaseClient? client})
    : _client = client ?? AgrisellSupabase.client {
    _deliveries = SupabaseRiderDeliveryRepository(
      SupabaseDeliveryDataSource(_client),
    );
  }

  final SupabaseClient _client;
  @override
  SupabaseClient get payoutClient => _client;
  late final RiderDeliveryRepository _deliveries;

  @override
  Future<RiderEarningsData> fetchEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  }) async {
    final delegate = await _deliveryDelegate(riderId);
    return delegate.fetchEarnings(riderId: riderId, dateRange: dateRange);
  }

  @override
  Future<List<RiderDeliveryHistoryEntry>> fetchHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  }) async {
    final delegate = await _deliveryDelegate(riderId);
    return delegate.fetchHistory(riderId: riderId, query: query);
  }

  @override
  Future<RiderRatingsData> fetchRatings({required String riderId}) async {
    final value = await _client.rpc<Object?>('current_rider_ratings');
    final data = _map(value);
    final summary = _map(data['summary']);
    final reviews = _rows(data['reviews'])
        .map(
          (row) => RiderReview(
            id: '${row['rating_id']}',
            deliveryId: '${row['delivery_id']}',
            reviewerRole: '${row['reviewer_role']}' == 'farmer'
                ? RiderReviewerRole.farmer
                : RiderReviewerRole.buyer,
            rating: (row['rating'] as num).toDouble(),
            createdAt: DateTime.parse('${row['created_at']}'),
            comment: _optionalText(row['comment']),
          ),
        )
        .toList(growable: false);
    return RiderRatingsData(
      summary: RiderRatingsSummary(
        averageRating: (summary['average_rating'] as num?)?.toDouble() ?? 0,
        totalRatings: (summary['total_ratings'] as num?)?.toInt() ?? 0,
        completedDeliveries:
            (summary['completed_deliveries'] as num?)?.toInt() ?? 0,
        cancellationRate:
            (summary['cancellation_rate'] as num?)?.toDouble() ?? 0,
        onTimeDeliveryRate:
            (summary['on_time_delivery_rate'] as num?)?.toDouble() ?? 0,
        acceptanceRate: (summary['acceptance_rate'] as num?)?.toDouble() ?? 0,
        completionRate: (summary['completion_rate'] as num?)?.toDouble() ?? 0,
      ),
      reviews: reviews,
    );
  }

  @override
  Future<void> submitRating(RiderRatingSubmission submission) async {
    await _client.rpc<Object?>(
      'submit_rider_rating',
      params: {
        'p_delivery_id': submission.deliveryId,
        'p_rating': submission.rating,
        'p_comment': submission.comment,
      },
    );
  }

  Future<RiderDeliveryAnalyticsRepository> _deliveryDelegate(
    String riderId,
  ) async {
    final records = await _deliveries.fetchCompletedDeliveries(riderId);
    return RiderDeliveryAnalyticsRepository(
      completionRecords: () =>
          List<DeliveryCompletionRecord>.unmodifiable(records),
    );
  }
}

List<Map<String, Object?>> _rows(Object? value) =>
    value is List ? value.map(_map).toList(growable: false) : const [];

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};

String? _optionalText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}
