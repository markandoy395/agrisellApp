class ProductReview {
  const ProductReview({
    required this.reviewerName,
    required this.rating,
    required this.comment,
    this.submittedAt,
  });

  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime? submittedAt;
}

class ProductReviewSummary {
  const ProductReviewSummary({
    required this.averageRating,
    required this.reviewCount,
    required this.reviews,
  });

  const ProductReviewSummary.empty()
    : averageRating = 0,
      reviewCount = 0,
      reviews = const [];

  final double averageRating;
  final int reviewCount;
  final List<ProductReview> reviews;
}
