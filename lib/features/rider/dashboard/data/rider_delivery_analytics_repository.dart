import '../domain/rider_analytics_models.dart';
import '../domain/rider_history_models.dart';
import '../domain/rider_rating_models.dart';
import '../domain/rider_withdrawal_models.dart';
import '../../deliveries/domain/delivery_completion.dart';
import '../../deliveries/domain/delivery_earning.dart';
import '../../deliveries/domain/delivery_status.dart';
import 'rider_analytics_repository.dart';
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
        if (_inRange(record.completedAt, dateRange)) _earningEntry(record),
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
        onTimePickupRate: _onTimePickupRate(records),
        onTimeDeliveryRate: _onTimeDeliveryRate(records),
        averageWaitingMinutes: _averageWaitingMinutes(records),
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

  RiderEarningEntry _earningEntry(DeliveryCompletionRecord record) {
    final earning =
        record.earning ??
        RiderDeliveryEarningCalculator.calculate(
          estimatedEarning: record.request.deliveryFee,
          fees: record.request.feeBreakdown,
        );
    return RiderEarningEntry(
      id: 'earning-${record.request.id}',
      deliveryId: record.request.id,
      orderNumber: record.request.orderNumber,
      occurredAt: record.completedAt,
      description: record.request.productName,
      amount: earning.finalEarning,
      type: RiderEarningType.deliveryFee,
      payoutStatus: earning.payoutStatus == DeliveryPayoutStatus.paid
          ? RiderPayoutStatus.paid
          : RiderPayoutStatus.pending,
      estimatedEarning: earning.estimatedEarning,
      finalEarning: earning.finalEarning,
      waitingAdjustment: earning.waitingAdjustment,
      returnAdjustment: earning.returnAdjustment,
      bonus: earning.bonus,
      incentive: earning.incentive,
      deduction: earning.deduction,
      penalty: earning.penalty,
    );
  }

  double _onTimePickupRate(List<DeliveryCompletionRecord> records) =>
      _rate(records, (record) {
        final pickedUp = record.events
            .where((event) => event.newStatus == DeliveryStatus.productPickedUp)
            .firstOrNull;
        return pickedUp != null &&
            !pickedUp.timestamp.isAfter(record.request.pickupDeadline);
      });

  double _onTimeDeliveryRate(List<DeliveryCompletionRecord> records) =>
      _rate(records, (record) {
        final deadline = record.request.deliveryDeadline;
        return deadline != null && !record.completedAt.isAfter(deadline);
      });

  double _averageWaitingMinutes(List<DeliveryCompletionRecord> records) {
    final durations = <Duration>[];
    for (final record in records) {
      for (var index = 0; index < record.events.length - 1; index++) {
        final status = record.events[index].newStatus;
        if (status == DeliveryStatus.waitingForProduct ||
            status == DeliveryStatus.waitingForBuyer) {
          durations.add(
            record.events[index + 1].timestamp.difference(
              record.events[index].timestamp,
            ),
          );
        }
      }
    }
    if (durations.isEmpty) return 0;
    return durations.fold<int>(0, (sum, item) => sum + item.inSeconds) /
        durations.length /
        60;
  }

  double _rate(
    List<DeliveryCompletionRecord> records,
    bool Function(DeliveryCompletionRecord) matches,
  ) => records.isEmpty
      ? 0
      : records.where(matches).length / records.length * 100;

  bool _inRange(DateTime value, RiderDateRange range) =>
      !value.isBefore(range.start) &&
      value.isBefore(range.end.add(const Duration(days: 1)));
}
