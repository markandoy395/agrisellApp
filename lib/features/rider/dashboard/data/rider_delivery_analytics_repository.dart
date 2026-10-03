import '../domain/rider_analytics_models.dart';
import '../domain/rider_history_models.dart';
import '../domain/rider_rating_models.dart';
import '../domain/rider_withdrawal_models.dart';
import '../../deliveries/domain/delivery_completion.dart';
import 'rider_analytics_repository.dart';
import 'rider_delivery_analytics_calculations.dart';
import 'rider_earnings_summary_builder.dart';

/// Bridges persisted delivery completions into Rider finance and performance.
class RiderDeliveryAnalyticsRepository implements RiderAnalyticsRepository {
  RiderDeliveryAnalyticsRepository({required this.completionRecords});

  final List<DeliveryCompletionRecord> Function() completionRecords;
  final Map<String, List<RiderReview>> _reviewsByRider = {};

  @override
  Future<List<RiderWithdrawalMethod>> fetchWithdrawalMethods({
    required String riderId,
  }) async => const [];

  @override
  Future<RiderWithdrawalMethod> saveWithdrawalMethod({
    required String riderId,
    required RiderWithdrawalMethod method,
  }) async => method;

  @override
  Future<void> deleteWithdrawalMethod({
    required String riderId,
    required String methodId,
  }) async {}

  @override
  Future<RiderWithdrawalRequest> submitWithdrawalRequest({
    required String riderId,
    required RiderWithdrawalRequest request,
  }) async => request;

  @override
  Future<List<RiderWithdrawalRequest>> fetchWithdrawalRequests({
    required String riderId,
  }) async => const [];

  @override
  Future<RiderEarningsData> fetchEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  }) async {
    final entries = <RiderEarningEntry>[
      for (final record in _forRider(riderId))
        if (RiderDeliveryAnalyticsCalculations.inDateRange(
          record.completedAt,
          dateRange,
        ))
          RiderDeliveryAnalyticsCalculations.earningEntry(record),
    ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return RiderEarningsData(
      summary: summarizeRiderEarnings(entries),
      entries: List.unmodifiable(entries),
    );
  }

  @override
  Future<List<RiderDeliveryHistoryEntry>> fetchHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  }) {
    final local = InMemoryRiderAnalyticsRepository(
      historyByRider: {
        riderId: [
          for (final record in _forRider(riderId))
            RiderDeliveryHistoryEntry.fromCompletion(record),
        ],
      },
    );
    return local.fetchHistory(riderId: riderId, query: query);
  }

  @override
  Future<RiderRatingsData> fetchRatings({required String riderId}) async {
    final records = _forRider(riderId);
    final reviews = _reviewsByRider[riderId] ?? const <RiderReview>[];
    final average = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0, (sum, review) => sum + review.rating) /
              reviews.length;
    return RiderRatingsData(
      summary: RiderRatingsSummary(
        averageRating: average,
        totalRatings: reviews.length,
        completedDeliveries: records.length,
        acceptanceRate: records.isEmpty ? 0 : 100,
        completionRate: records.isEmpty ? 0 : 100,
        onTimePickupRate:
            RiderDeliveryAnalyticsCalculations.onTimePickupRate(records),
        onTimeDeliveryRate:
            RiderDeliveryAnalyticsCalculations.onTimeDeliveryRate(records),
        averageWaitingMinutes:
            RiderDeliveryAnalyticsCalculations.averageWaitingMinutes(records),
      ),
      reviews: List.unmodifiable(reviews),
    );
  }

  @override
  Future<void> submitRating(RiderRatingSubmission submission) async {
    final completed = _forRider(
      submission.riderId,
    ).any((record) => record.request.id == submission.deliveryId);
    if (!completed) {
      throw StateError('Ratings require a verified completed delivery.');
    }
    final id = '${submission.deliveryId}:${submission.reviewerKey}';
    final reviews = _reviewsByRider.putIfAbsent(submission.riderId, () => []);
    if (reviews.any((review) => review.id == id)) {
      throw StateError('This reviewer has already rated this delivery.');
    }
    reviews.add(
      RiderReview(
        id: id,
        deliveryId: submission.deliveryId,
        reviewerRole: submission.reviewerRole,
        rating: submission.rating,
        createdAt: DateTime.now(),
        comment: submission.comment,
      ),
    );
  }

  List<DeliveryCompletionRecord> _forRider(String riderId) =>
      completionRecords()
          .where((record) => record.request.isAssignedTo(riderId))
          .toList(growable: false);
}
