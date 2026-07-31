enum RiderReviewerRole { buyer, farmer }

extension RiderReviewerRoleDetails on RiderReviewerRole {
  String get label => this == RiderReviewerRole.buyer ? 'Buyer' : 'Farmer';
}

class RiderReview {
  const RiderReview({
    required this.id,
    required this.deliveryId,
    required this.reviewerRole,
    required this.rating,
    required this.createdAt,
    this.reviewerDisplayName,
    this.comment,
  }) : assert(id != ''),
       assert(deliveryId != ''),
       assert(rating >= 1 && rating <= 5);

  final String id;
  final String deliveryId;
  final RiderReviewerRole reviewerRole;
  final double rating;
  final DateTime createdAt;
  final String? reviewerDisplayName;
  final String? comment;
}

class RiderRatingsSummary {
  const RiderRatingsSummary({
    this.averageRating = 0,
    this.totalRatings = 0,
    this.completedDeliveries = 0,
    this.cancellationRate = 0,
    this.onTimeDeliveryRate = 0,
    this.acceptanceRate = 0,
    this.completionRate = 0,
    this.onTimePickupRate = 0,
    this.averageWaitingMinutes = 0,
    this.failedDeliveryRate = 0,
  }) : assert(averageRating >= 0 && averageRating <= 5),
       assert(totalRatings >= 0),
       assert(completedDeliveries >= 0),
       assert(cancellationRate >= 0 && cancellationRate <= 100),
       assert(onTimeDeliveryRate >= 0 && onTimeDeliveryRate <= 100);

  const RiderRatingsSummary.empty() : this();

  final double averageRating;
  final int totalRatings;
  final int completedDeliveries;
  final double cancellationRate;
  final double onTimeDeliveryRate;
  final double acceptanceRate;
  final double completionRate;
  final double onTimePickupRate;
  final double averageWaitingMinutes;
  final double failedDeliveryRate;

  bool get isEmpty => totalRatings == 0 && completedDeliveries == 0;
}

class RiderRatingsData {
  const RiderRatingsData({
    required this.summary,
    this.reviews = const <RiderReview>[],
  });

  const RiderRatingsData.empty()
    : summary = const RiderRatingsSummary.empty(),
      reviews = const <RiderReview>[];

  final RiderRatingsSummary summary;
  final List<RiderReview> reviews;

  bool get hasData => !summary.isEmpty || reviews.isNotEmpty;
}

/// Submitted by a buyer or farmer only after a server-verified delivery.
class RiderRatingSubmission {
  const RiderRatingSubmission({
    required this.riderId,
    required this.deliveryId,
    required this.reviewerRole,
    required this.rating,
    this.comment,
    this.reviewerId,
  }) : assert(riderId != ''),
       assert(deliveryId != ''),
       assert(rating >= 1 && rating <= 5);

  final String riderId;
  final String deliveryId;
  final RiderReviewerRole reviewerRole;
  final double rating;
  final String? comment;
  final String? reviewerId;

  String get reviewerKey => reviewerId?.trim().isNotEmpty ?? false
      ? reviewerId!.trim()
      : reviewerRole.name;
}
