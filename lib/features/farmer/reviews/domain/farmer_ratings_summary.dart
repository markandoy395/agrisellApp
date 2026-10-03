part of 'farmer_review_models.dart';

class FarmerRatingsSummary {
  const FarmerRatingsSummary({
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.fiveStarCount = 0,
    this.fourStarCount = 0,
    this.threeStarCount = 0,
    this.twoStarCount = 0,
    this.oneStarCount = 0,
    this.moderatedCount = 0,
  }) : assert(averageRating >= 0.0 && averageRating <= 5.0),
       assert(totalReviews >= 0);

  const FarmerRatingsSummary.empty() : this();

  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final int moderatedCount;

  bool get isEmpty => totalReviews == 0;

  double get fiveStarPercent =>
      totalReviews > 0 ? (fiveStarCount * 100.0) / totalReviews : 0.0;
  double get fourStarPercent =>
      totalReviews > 0 ? (fourStarCount * 100.0) / totalReviews : 0.0;
  double get threeStarPercent =>
      totalReviews > 0 ? (threeStarCount * 100.0) / totalReviews : 0.0;
  double get twoStarPercent =>
      totalReviews > 0 ? (twoStarCount * 100.0) / totalReviews : 0.0;
  double get oneStarPercent =>
      totalReviews > 0 ? (oneStarCount * 100.0) / totalReviews : 0.0;

  factory FarmerRatingsSummary.fromJson(Map<String, dynamic> json) {
    return FarmerRatingsSummary(
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      fiveStarCount: (json['five_star_count'] as num?)?.toInt() ?? 0,
      fourStarCount: (json['four_star_count'] as num?)?.toInt() ?? 0,
      threeStarCount: (json['three_star_count'] as num?)?.toInt() ?? 0,
      twoStarCount: (json['two_star_count'] as num?)?.toInt() ?? 0,
      oneStarCount: (json['one_star_count'] as num?)?.toInt() ?? 0,
      moderatedCount: (json['moderated_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'average_rating': averageRating,
    'total_reviews': totalReviews,
    'five_star_count': fiveStarCount,
    'four_star_count': fourStarCount,
    'three_star_count': threeStarCount,
    'two_star_count': twoStarCount,
    'one_star_count': oneStarCount,
    'moderated_count': moderatedCount,
  };
}

class FarmerReviewsData {
  const FarmerReviewsData({
    required this.summary,
    this.reviews = const <FarmerReview>[],
  });

  const FarmerReviewsData.empty()
      : summary = const FarmerRatingsSummary.empty(),
        reviews = const <FarmerReview>[];

  final FarmerRatingsSummary summary;
  final List<FarmerReview> reviews;

  bool get hasData => !summary.isEmpty || reviews.isNotEmpty;
}
