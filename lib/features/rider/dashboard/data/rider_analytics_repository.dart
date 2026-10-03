import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_withdrawal_models.dart';

export 'in_memory_rider_analytics_repository.dart';

/// Server contract for rider earnings, delivery history, and ratings.
abstract interface class RiderAnalyticsRepository {
  Future<RiderEarningsData> fetchEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  });

  Future<List<RiderDeliveryHistoryEntry>> fetchHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  });

  Future<RiderRatingsData> fetchRatings({required String riderId});

  /// The remote implementation must verify a completed delivery and reviewer
  /// role before accepting this submission.
  Future<void> submitRating(RiderRatingSubmission submission);

  Future<List<RiderWithdrawalMethod>> fetchWithdrawalMethods({
    required String riderId,
  });

  Future<RiderWithdrawalMethod> saveWithdrawalMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  });

  Future<void> deleteWithdrawalMethod({
    required String riderId,
    required String methodId,
  });

  Future<RiderWithdrawalRequest> submitWithdrawalRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  });

  Future<List<RiderWithdrawalRequest>> fetchWithdrawalRequests({
    required String riderId,
  });
}
