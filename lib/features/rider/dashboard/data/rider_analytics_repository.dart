import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_rating_models.dart';
import 'package:agresell_app/features/rider/dashboard/data/rider_earnings_summary_builder.dart';

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
}

/// Empty local adapter for development and widget tests.
///
/// It intentionally contains no seeded earnings, history, ratings, or reviews.
class InMemoryRiderAnalyticsRepository implements RiderAnalyticsRepository {
  InMemoryRiderAnalyticsRepository({
    Map<String, RiderEarningsData> earningsByRider = const {},
    Map<String, List<RiderDeliveryHistoryEntry>> historyByRider = const {},
    Map<String, RiderRatingsData> ratingsByRider = const {},
  }) : _earningsByRider = {...earningsByRider},
       _historyByRider = {
         for (final entry in historyByRider.entries)
           entry.key: [...entry.value],
       },
       _ratingsByRider = {...ratingsByRider};

  final Map<String, RiderEarningsData> _earningsByRider;
  final Map<String, List<RiderDeliveryHistoryEntry>> _historyByRider;
  final Map<String, RiderRatingsData> _ratingsByRider;

  @override
  Future<RiderEarningsData> fetchEarnings({
    required String riderId,
    required RiderDateRange dateRange,
  }) async {
    final data = _earningsByRider[riderId] ?? const RiderEarningsData.empty();
    if (data.entries.isEmpty) return data;
    final entries = data.entries
        .where((entry) => _inRange(entry.occurredAt, dateRange))
        .toList(growable: false);
    return RiderEarningsData(
      summary: summarizeRiderEarnings(entries),
      entries: entries,
    );
  }

  @override
  Future<List<RiderDeliveryHistoryEntry>> fetchHistory({
    required String riderId,
    RiderHistoryQuery query = const RiderHistoryQuery(),
  }) async {
    final records = _historyByRider[riderId] ?? const [];
    return records.where((record) => _matches(record, query)).toList();
  }

  @override
  Future<RiderRatingsData> fetchRatings({required String riderId}) async {
    return _ratingsByRider[riderId] ?? const RiderRatingsData.empty();
  }

  @override
  Future<void> submitRating(RiderRatingSubmission submission) async {
    final completed =
        _historyByRider[submission.riderId]?.any(
          (entry) =>
              entry.id == submission.deliveryId &&
              entry.status == RiderHistoryStatus.completed,
        ) ??
        false;
    if (!completed) {
      throw StateError('Ratings require a verified completed delivery.');
    }
    final current =
        _ratingsByRider[submission.riderId] ?? const RiderRatingsData.empty();
    final id = '${submission.deliveryId}:${submission.reviewerKey}';
    if (current.reviews.any((review) => review.id == id)) {
      throw StateError('This reviewer has already rated this delivery.');
    }
    final review = RiderReview(
      id: id,
      deliveryId: submission.deliveryId,
      reviewerRole: submission.reviewerRole,
      rating: submission.rating,
      createdAt: DateTime.now(),
      comment: submission.comment,
    );
    final reviews = [...current.reviews, review];
    final average =
        reviews.fold<double>(0, (total, item) => total + item.rating) /
        reviews.length;
    _ratingsByRider[submission.riderId] = RiderRatingsData(
      summary: RiderRatingsSummary(
        averageRating: average,
        totalRatings: reviews.length,
        completedDeliveries: current.summary.completedDeliveries,
        cancellationRate: current.summary.cancellationRate,
        onTimeDeliveryRate: current.summary.onTimeDeliveryRate,
        acceptanceRate: current.summary.acceptanceRate,
        completionRate: current.summary.completionRate,
        onTimePickupRate: current.summary.onTimePickupRate,
        averageWaitingMinutes: current.summary.averageWaitingMinutes,
        failedDeliveryRate: current.summary.failedDeliveryRate,
      ),
      reviews: reviews,
    );
  }

  bool _matches(RiderDeliveryHistoryEntry record, RiderHistoryQuery query) {
    final range = query.dateRange;
    final inRange =
        range == null ||
        (!record.completedAt.isBefore(range.start) &&
            record.completedAt.isBefore(
              range.end.add(const Duration(days: 1)),
            ));
    return (query.status == null || record.status == query.status) &&
        (query.paymentStatus == null ||
            record.paymentStatus == query.paymentStatus) &&
        _contains(record.productName, query.product) &&
        _contains(record.sellerName, query.seller) &&
        _contains(record.buyerName, query.buyer) &&
        _contains(record.pickupAddress, query.pickupLocation) &&
        _contains(record.deliveryAddress, query.deliveryLocation) &&
        record.matchesSearch(query.searchTerm) &&
        inRange;
  }

  bool _contains(String value, String? query) =>
      query == null ||
      query.trim().isEmpty ||
      value.toLowerCase().contains(query.trim().toLowerCase());

  bool _inRange(DateTime value, RiderDateRange range) =>
      !value.isBefore(range.start) &&
      value.isBefore(range.end.add(const Duration(days: 1)));
}
